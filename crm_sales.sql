/*=====================================================================
  CRM - Product sales, services, warranties and customer loyalty
  Target : Microsoft SQL Server 2025 Standard
  Run on : an empty server/instance, in SSMS or sqlcmd (uses GO batches)
  Order  : 1 database  2 schemas  3 tables  4 indexes  5 triggers
           6 views     7 procedures  8 seed data  9 security
  Notes  : - Temporal tables: Customer, Consent, Warranty, LoyaltyAccount
           - Money = DECIMAL(18,2); dates = DATETIME2 / DATE
           - Loyalty ledger is append-only; balance is a cached total
=====================================================================*/

/*---------------------------------------------------------------
  1. DATABASE
---------------------------------------------------------------*/
USE master;
GO
IF DB_ID(N'CrmSales') IS NULL
    CREATE DATABASE CrmSales COLLATE Latin1_General_100_CI_AI_SC;
GO
ALTER DATABASE CrmSales SET RECOVERY FULL;
ALTER DATABASE CrmSales SET READ_COMMITTED_SNAPSHOT ON WITH ROLLBACK IMMEDIATE;
ALTER DATABASE CrmSales SET ALLOW_SNAPSHOT_ISOLATION ON;
ALTER DATABASE CrmSales SET QUERY_STORE = ON;
GO
USE CrmSales;
GO

/*---------------------------------------------------------------
  2. SCHEMAS
---------------------------------------------------------------*/
IF SCHEMA_ID(N'sec')       IS NULL EXEC(N'CREATE SCHEMA sec       AUTHORIZATION dbo;');
IF SCHEMA_ID(N'crm')       IS NULL EXEC(N'CREATE SCHEMA crm       AUTHORIZATION dbo;');
IF SCHEMA_ID(N'sales')     IS NULL EXEC(N'CREATE SCHEMA sales     AUTHORIZATION dbo;');
IF SCHEMA_ID(N'warranty')  IS NULL EXEC(N'CREATE SCHEMA warranty  AUTHORIZATION dbo;');
IF SCHEMA_ID(N'service')   IS NULL EXEC(N'CREATE SCHEMA service   AUTHORIZATION dbo;');
IF SCHEMA_ID(N'loyalty')   IS NULL EXEC(N'CREATE SCHEMA loyalty   AUTHORIZATION dbo;');
IF SCHEMA_ID(N'marketing') IS NULL EXEC(N'CREATE SCHEMA marketing AUTHORIZATION dbo;');
GO

/*---------------------------------------------------------------
  3. TABLES
---------------------------------------------------------------*/

/* ---------- sec.AppUser ---------- */
CREATE TABLE sec.AppUser
(
    UserId       INT IDENTITY(1,1) NOT NULL,
    Username     NVARCHAR(100) NOT NULL,
    DisplayName  NVARCHAR(150) NOT NULL,
    Email        NVARCHAR(254) NULL,
    Role         NVARCHAR(20)  NOT NULL,
    ExternalId   NVARCHAR(100) NULL,           -- e.g. Entra ID object id
    IsActive     BIT NOT NULL DEFAULT 1,
    CreatedAt    DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_AppUser PRIMARY KEY CLUSTERED (UserId),
    CONSTRAINT UQ_AppUser_Username UNIQUE (Username),
    CONSTRAINT CK_AppUser_Role CHECK (Role IN
        (N'Admin', N'Manager', N'Sales', N'Technician', N'WarrantyAdmin', N'Marketing'))
);
GO

/* ---------- crm.Customer (temporal, masked contact data) ---------- */
CREATE TABLE crm.Customer
(
    CustomerId           INT IDENTITY(1,1) NOT NULL,
    CustomerCode         AS (N'CUS-' + RIGHT(N'00000000' + CONVERT(NVARCHAR(10), CustomerId), 8)) PERSISTED NOT NULL,
    CustomerType         NVARCHAR(10)  NOT NULL DEFAULT N'Person',
    FullName             NVARCHAR(150) NOT NULL,
    NationalId           NVARCHAR(30)  NULL,       -- cedula / RNC / passport
    Email                NVARCHAR(254) MASKED WITH (FUNCTION = 'email()') NULL,
    Phone                NVARCHAR(30)  MASKED WITH (FUNCTION = 'partial(0,"XXX-XXX-",4)') NULL,
    BirthDate            DATE NULL,
    Segment              NVARCHAR(30)  NULL,       -- e.g. RFM segment, maintained by a job
    ReferredByCustomerId INT NULL,
    IsActive             BIT NOT NULL DEFAULT 1,
    CreatedAt            DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    UpdatedAt            DATETIME2(0) NULL,
    SysStartTime         DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
    SysEndTime           DATETIME2 GENERATED ALWAYS AS ROW END   HIDDEN NOT NULL,
    PERIOD FOR SYSTEM_TIME (SysStartTime, SysEndTime),
    CONSTRAINT PK_Customer PRIMARY KEY CLUSTERED (CustomerId),
    CONSTRAINT FK_Customer_ReferredBy FOREIGN KEY (ReferredByCustomerId) REFERENCES crm.Customer (CustomerId),
    CONSTRAINT CK_Customer_Type CHECK (CustomerType IN (N'Person', N'Company')),
    CONSTRAINT CK_Customer_Contact CHECK (Email IS NOT NULL OR Phone IS NOT NULL)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = crm.CustomerHistory));
GO

/* ---------- crm.CustomerAddress ---------- */
CREATE TABLE crm.CustomerAddress
(
    AddressId   INT IDENTITY(1,1) NOT NULL,
    CustomerId  INT NOT NULL,
    AddressType NVARCHAR(10)  NOT NULL DEFAULT N'Home',
    Line1       NVARCHAR(200) NOT NULL,
    Line2       NVARCHAR(200) NULL,
    City        NVARCHAR(100) NOT NULL,
    Province    NVARCHAR(100) NULL,
    PostalCode  NVARCHAR(20)  NULL,
    Country     NCHAR(2) NOT NULL DEFAULT N'DO',
    IsDefault   BIT NOT NULL DEFAULT 0,
    CreatedAt   DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_CustomerAddress PRIMARY KEY CLUSTERED (AddressId),
    CONSTRAINT FK_CustomerAddress_Customer FOREIGN KEY (CustomerId) REFERENCES crm.Customer (CustomerId),
    CONSTRAINT CK_CustomerAddress_Type CHECK (AddressType IN (N'Home', N'Work', N'Billing', N'Shipping'))
);
GO

/* ---------- crm.Consent (temporal: legal evidence of opt-in/out) ---------- */
CREATE TABLE crm.Consent
(
    ConsentId    INT IDENTITY(1,1) NOT NULL,
    CustomerId   INT NOT NULL,
    Channel      NVARCHAR(15) NOT NULL,
    OptIn        BIT NOT NULL,
    Source       NVARCHAR(50) NULL,              -- web form, store, call...
    UpdatedAt    DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    SysStartTime DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
    SysEndTime   DATETIME2 GENERATED ALWAYS AS ROW END   HIDDEN NOT NULL,
    PERIOD FOR SYSTEM_TIME (SysStartTime, SysEndTime),
    CONSTRAINT PK_Consent PRIMARY KEY CLUSTERED (ConsentId),
    CONSTRAINT UQ_Consent_CustomerChannel UNIQUE (CustomerId, Channel),
    CONSTRAINT FK_Consent_Customer FOREIGN KEY (CustomerId) REFERENCES crm.Customer (CustomerId),
    CONSTRAINT CK_Consent_Channel CHECK (Channel IN (N'Email', N'SMS', N'WhatsApp', N'Phone', N'Mail'))
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = crm.ConsentHistory));
GO

/* ---------- crm.Interaction (high volume log) ---------- */
CREATE TABLE crm.Interaction
(
    InteractionId BIGINT IDENTITY(1,1) NOT NULL,
    CustomerId    INT NOT NULL,
    UserId        INT NULL,
    Channel       NVARCHAR(15) NOT NULL,
    Type          NVARCHAR(30) NOT NULL,         -- Call, Visit, Email, Complaint, Note...
    Subject       NVARCHAR(200) NULL,
    Notes         NVARCHAR(MAX) NULL,
    OccurredAt    DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Interaction PRIMARY KEY CLUSTERED (InteractionId),
    CONSTRAINT FK_Interaction_Customer FOREIGN KEY (CustomerId) REFERENCES crm.Customer (CustomerId),
    CONSTRAINT FK_Interaction_User FOREIGN KEY (UserId) REFERENCES sec.AppUser (UserId)
);
GO

/* ---------- sales.ProductCategory ---------- */
CREATE TABLE sales.ProductCategory
(
    CategoryId INT IDENTITY(1,1) NOT NULL,
    ParentId   INT NULL,
    Name       NVARCHAR(100) NOT NULL,
    CONSTRAINT PK_ProductCategory PRIMARY KEY CLUSTERED (CategoryId),
    CONSTRAINT FK_ProductCategory_Parent FOREIGN KEY (ParentId) REFERENCES sales.ProductCategory (CategoryId)
);
GO

/* ---------- sales.Product ---------- */
CREATE TABLE sales.Product
(
    ProductId             INT IDENTITY(1,1) NOT NULL,
    CategoryId            INT NOT NULL,
    Sku                   NVARCHAR(50)  NOT NULL,
    Name                  NVARCHAR(200) NOT NULL,
    Description           NVARCHAR(MAX) NULL,
    ListPrice             DECIMAL(18,2) NOT NULL,
    Cost                  DECIMAL(18,2) NULL,
    DefaultWarrantyMonths INT NOT NULL DEFAULT 12,
    TracksSerial          BIT NOT NULL DEFAULT 1,
    Specs                 NVARCHAR(MAX) NULL,    -- JSON; can be migrated to the native json type
    IsActive              BIT NOT NULL DEFAULT 1,
    CreatedAt             DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    UpdatedAt             DATETIME2(0) NULL,
    CONSTRAINT PK_Product PRIMARY KEY CLUSTERED (ProductId),
    CONSTRAINT UQ_Product_Sku UNIQUE (Sku),
    CONSTRAINT FK_Product_Category FOREIGN KEY (CategoryId) REFERENCES sales.ProductCategory (CategoryId),
    CONSTRAINT CK_Product_Price CHECK (ListPrice >= 0 AND (Cost IS NULL OR Cost >= 0)),
    CONSTRAINT CK_Product_Warranty CHECK (DefaultWarrantyMonths >= 0),
    CONSTRAINT CK_Product_Specs CHECK (Specs IS NULL OR ISJSON(Specs) = 1)
);
GO

/* ---------- sales.ServiceCatalog ---------- */
CREATE TABLE sales.ServiceCatalog
(
    ServiceId   INT IDENTITY(1,1) NOT NULL,
    ServiceCode NVARCHAR(30)  NOT NULL,
    Name        NVARCHAR(150) NOT NULL,
    Description NVARCHAR(MAX) NULL,
    StdPrice    DECIMAL(18,2) NOT NULL DEFAULT 0,
    IsRecurring BIT NOT NULL DEFAULT 0,
    SlaHours    INT NOT NULL DEFAULT 48,
    IsActive    BIT NOT NULL DEFAULT 1,
    CONSTRAINT PK_ServiceCatalog PRIMARY KEY CLUSTERED (ServiceId),
    CONSTRAINT UQ_ServiceCatalog_Code UNIQUE (ServiceCode),
    CONSTRAINT CK_ServiceCatalog_Price CHECK (StdPrice >= 0 AND SlaHours > 0)
);
GO

/* ---------- sales.SalesOrder ---------- */
CREATE TABLE sales.SalesOrder
(
    OrderId      INT IDENTITY(1,1) NOT NULL,
    OrderNumber  AS (N'SO-' + RIGHT(N'00000000' + CONVERT(NVARCHAR(10), OrderId), 8)) PERSISTED NOT NULL,
    CustomerId   INT NOT NULL,
    SoldByUserId INT NULL,
    OrderDate    DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    Status       NVARCHAR(15) NOT NULL DEFAULT N'Draft',
    Total        DECIMAL(18,2) NOT NULL DEFAULT 0,    -- maintained by trigger on OrderLine
    Notes        NVARCHAR(500) NULL,
    CreatedAt    DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    UpdatedAt    DATETIME2(0) NULL,
    RowVer       ROWVERSION NOT NULL,
    CONSTRAINT PK_SalesOrder PRIMARY KEY CLUSTERED (OrderId),
    CONSTRAINT FK_SalesOrder_Customer FOREIGN KEY (CustomerId) REFERENCES crm.Customer (CustomerId),
    CONSTRAINT FK_SalesOrder_User FOREIGN KEY (SoldByUserId) REFERENCES sec.AppUser (UserId),
    CONSTRAINT CK_SalesOrder_Status CHECK (Status IN
        (N'Draft', N'Confirmed', N'Completed', N'Cancelled', N'Refunded')),
    CONSTRAINT CK_SalesOrder_Total CHECK (Total >= 0)
);
GO

/* ---------- sales.OrderLine ---------- */
CREATE TABLE sales.OrderLine
(
    OrderLineId INT IDENTITY(1,1) NOT NULL,
    OrderId     INT NOT NULL,
    ProductId   INT NULL,
    ServiceId   INT NULL,
    Qty         INT NOT NULL,
    UnitPrice   DECIMAL(18,2) NOT NULL,
    DiscountPct DECIMAL(5,2)  NOT NULL DEFAULT 0,
    LineTotal   AS (CAST(Qty * UnitPrice * (1 - DiscountPct / 100.0) AS DECIMAL(18,2))) PERSISTED NOT NULL,
    CONSTRAINT PK_OrderLine PRIMARY KEY CLUSTERED (OrderLineId),
    CONSTRAINT FK_OrderLine_Order FOREIGN KEY (OrderId) REFERENCES sales.SalesOrder (OrderId),
    CONSTRAINT FK_OrderLine_Product FOREIGN KEY (ProductId) REFERENCES sales.Product (ProductId),
    CONSTRAINT FK_OrderLine_Service FOREIGN KEY (ServiceId) REFERENCES sales.ServiceCatalog (ServiceId),
    CONSTRAINT CK_OrderLine_Item CHECK ((ProductId IS NOT NULL AND ServiceId IS NULL)
                                     OR (ProductId IS NULL AND ServiceId IS NOT NULL)),
    CONSTRAINT CK_OrderLine_Values CHECK (Qty > 0 AND UnitPrice >= 0 AND DiscountPct BETWEEN 0 AND 100)
);
GO

/* ---------- sales.ProductUnit (serial-numbered physical item) ---------- */
CREATE TABLE sales.ProductUnit
(
    UnitId       INT IDENTITY(1,1) NOT NULL,
    ProductId    INT NOT NULL,
    OrderLineId  INT NULL,                       -- NULL while in stock
    SerialNumber NVARCHAR(100) NOT NULL,
    Status       NVARCHAR(10) NOT NULL DEFAULT N'InStock',
    SoldOn       DATE NULL,
    CreatedAt    DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_ProductUnit PRIMARY KEY CLUSTERED (UnitId),
    CONSTRAINT UQ_ProductUnit_Serial UNIQUE (ProductId, SerialNumber),
    CONSTRAINT FK_ProductUnit_Product FOREIGN KEY (ProductId) REFERENCES sales.Product (ProductId),
    CONSTRAINT FK_ProductUnit_OrderLine FOREIGN KEY (OrderLineId) REFERENCES sales.OrderLine (OrderLineId),
    CONSTRAINT CK_ProductUnit_Status CHECK (Status IN (N'InStock', N'Sold', N'Returned', N'Scrapped')),
    CONSTRAINT CK_ProductUnit_Sold CHECK (Status <> N'Sold' OR (OrderLineId IS NOT NULL AND SoldOn IS NOT NULL))
);
GO

/* ---------- sales.Payment ---------- */
CREATE TABLE sales.Payment
(
    PaymentId INT IDENTITY(1,1) NOT NULL,
    OrderId   INT NOT NULL,
    Method    NVARCHAR(10) NOT NULL,
    Amount    DECIMAL(18,2) NOT NULL,
    Reference NVARCHAR(100) NULL,
    Status    NVARCHAR(10) NOT NULL DEFAULT N'Posted',
    PaidAt    DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Payment PRIMARY KEY CLUSTERED (PaymentId),
    CONSTRAINT FK_Payment_Order FOREIGN KEY (OrderId) REFERENCES sales.SalesOrder (OrderId),
    CONSTRAINT CK_Payment_Method CHECK (Method IN (N'Cash', N'Card', N'Transfer', N'Check', N'Credit', N'Points')),
    CONSTRAINT CK_Payment_Status CHECK (Status IN (N'Posted', N'Reversed')),
    CONSTRAINT CK_Payment_Amount CHECK (Amount > 0)
);
GO

/* ---------- warranty.WarrantyPlan ---------- */
CREATE TABLE warranty.WarrantyPlan
(
    PlanId         INT IDENTITY(1,1) NOT NULL,
    PlanCode       NVARCHAR(20)  NOT NULL,
    Name           NVARCHAR(100) NOT NULL,
    PlanType       NVARCHAR(10)  NOT NULL DEFAULT N'Extended',
    DurationMonths INT NOT NULL,
    Coverage       NVARCHAR(1000) NULL,
    Price          DECIMAL(18,2) NOT NULL DEFAULT 0,
    IsActive       BIT NOT NULL DEFAULT 1,
    CONSTRAINT PK_WarrantyPlan PRIMARY KEY CLUSTERED (PlanId),
    CONSTRAINT UQ_WarrantyPlan_Code UNIQUE (PlanCode),
    CONSTRAINT CK_WarrantyPlan_Type CHECK (PlanType IN (N'Standard', N'Extended')),
    CONSTRAINT CK_WarrantyPlan_Values CHECK (DurationMonths > 0 AND Price >= 0)
);
GO

/* ---------- warranty.Warranty (temporal) ---------- */
CREATE TABLE warranty.Warranty
(
    WarrantyId     INT IDENTITY(1,1) NOT NULL,
    UnitId         INT NOT NULL,
    PlanId         INT NOT NULL,
    StartDate      DATE NOT NULL,
    DurationMonths INT NOT NULL,
    EndDate        AS (DATEADD(MONTH, DurationMonths, StartDate)) PERSISTED NOT NULL,
    Status         NVARCHAR(10) NOT NULL DEFAULT N'Active',
    CreatedAt      DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    SysStartTime   DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
    SysEndTime     DATETIME2 GENERATED ALWAYS AS ROW END   HIDDEN NOT NULL,
    PERIOD FOR SYSTEM_TIME (SysStartTime, SysEndTime),
    CONSTRAINT PK_Warranty PRIMARY KEY CLUSTERED (WarrantyId),
    CONSTRAINT FK_Warranty_Unit FOREIGN KEY (UnitId) REFERENCES sales.ProductUnit (UnitId),
    CONSTRAINT FK_Warranty_Plan FOREIGN KEY (PlanId) REFERENCES warranty.WarrantyPlan (PlanId),
    CONSTRAINT CK_Warranty_Status CHECK (Status IN (N'Pending', N'Active', N'Expired', N'Void')),
    CONSTRAINT CK_Warranty_Duration CHECK (DurationMonths > 0)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = warranty.WarrantyHistory));
GO

/* ---------- warranty.WarrantyClaim ---------- */
CREATE TABLE warranty.WarrantyClaim
(
    ClaimId         INT IDENTITY(1,1) NOT NULL,
    WarrantyId      INT NOT NULL,
    ClaimDate       DATE NOT NULL DEFAULT CAST(SYSUTCDATETIME() AS DATE),
    Issue           NVARCHAR(1000) NOT NULL,
    Decision        NVARCHAR(10) NOT NULL DEFAULT N'Pending',
    DecisionNotes   NVARCHAR(1000) NULL,
    DecidedAt       DATETIME2(0) NULL,
    DecidedByUserId INT NULL,
    CreatedAt       DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_WarrantyClaim PRIMARY KEY CLUSTERED (ClaimId),
    CONSTRAINT FK_WarrantyClaim_Warranty FOREIGN KEY (WarrantyId) REFERENCES warranty.Warranty (WarrantyId),
    CONSTRAINT FK_WarrantyClaim_User FOREIGN KEY (DecidedByUserId) REFERENCES sec.AppUser (UserId),
    CONSTRAINT CK_WarrantyClaim_Decision CHECK (Decision IN (N'Pending', N'Approved', N'Rejected'))
);
GO

/* ---------- service.ServiceTicket ---------- */
CREATE TABLE service.ServiceTicket
(
    TicketId       INT IDENTITY(1,1) NOT NULL,
    TicketNumber   AS (N'TK-' + RIGHT(N'00000000' + CONVERT(NVARCHAR(10), TicketId), 8)) PERSISTED NOT NULL,
    CustomerId     INT NOT NULL,
    ServiceId      INT NOT NULL,
    UnitId         INT NULL,
    ClaimId        INT NULL,
    AssignedUserId INT NULL,
    Priority       NVARCHAR(10) NOT NULL DEFAULT N'Normal',
    Status         NVARCHAR(12) NOT NULL DEFAULT N'Open',
    Description    NVARCHAR(2000) NULL,
    Resolution     NVARCHAR(2000) NULL,
    OpenedAt       DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    DueAt          DATETIME2(0) NULL,            -- OpenedAt + ServiceCatalog.SlaHours (set by app)
    ClosedAt       DATETIME2(0) NULL,
    CreatedAt      DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    UpdatedAt      DATETIME2(0) NULL,
    RowVer         ROWVERSION NOT NULL,
    CONSTRAINT PK_ServiceTicket PRIMARY KEY CLUSTERED (TicketId),
    CONSTRAINT FK_ServiceTicket_Customer FOREIGN KEY (CustomerId) REFERENCES crm.Customer (CustomerId),
    CONSTRAINT FK_ServiceTicket_Service FOREIGN KEY (ServiceId) REFERENCES sales.ServiceCatalog (ServiceId),
    CONSTRAINT FK_ServiceTicket_Unit FOREIGN KEY (UnitId) REFERENCES sales.ProductUnit (UnitId),
    CONSTRAINT FK_ServiceTicket_Claim FOREIGN KEY (ClaimId) REFERENCES warranty.WarrantyClaim (ClaimId),
    CONSTRAINT FK_ServiceTicket_User FOREIGN KEY (AssignedUserId) REFERENCES sec.AppUser (UserId),
    CONSTRAINT CK_ServiceTicket_Priority CHECK (Priority IN (N'Low', N'Normal', N'High', N'Urgent')),
    CONSTRAINT CK_ServiceTicket_Status CHECK (Status IN (N'Open', N'InProgress', N'OnHold', N'Resolved', N'Closed', N'Cancelled')),
    CONSTRAINT CK_ServiceTicket_Dates CHECK (ClosedAt IS NULL OR ClosedAt >= OpenedAt)
);
GO

/* ---------- loyalty.LoyaltyTier ---------- */
CREATE TABLE loyalty.LoyaltyTier
(
    TierId           INT IDENTITY(1,1) NOT NULL,
    Name             NVARCHAR(50) NOT NULL,
    MinPoints        INT NOT NULL,               -- points earned in the last 12 months
    PointsMultiplier DECIMAL(5,2) NOT NULL DEFAULT 1,
    Perks            NVARCHAR(500) NULL,
    CONSTRAINT PK_LoyaltyTier PRIMARY KEY CLUSTERED (TierId),
    CONSTRAINT UQ_LoyaltyTier_Name UNIQUE (Name),
    CONSTRAINT UQ_LoyaltyTier_Min UNIQUE (MinPoints),
    CONSTRAINT CK_LoyaltyTier_Values CHECK (MinPoints >= 0 AND PointsMultiplier >= 1)
);
GO

/* ---------- loyalty.LoyaltyAccount (temporal) ---------- */
CREATE TABLE loyalty.LoyaltyAccount
(
    LoyaltyId     INT IDENTITY(1,1) NOT NULL,
    CustomerId    INT NOT NULL,
    TierId        INT NOT NULL,
    PointsBalance INT NOT NULL DEFAULT 0,
    EnrolledOn    DATE NOT NULL DEFAULT CAST(SYSUTCDATETIME() AS DATE),
    Status        NVARCHAR(10) NOT NULL DEFAULT N'Active',
    CreatedAt     DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    UpdatedAt     DATETIME2(0) NULL,
    SysStartTime  DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
    SysEndTime    DATETIME2 GENERATED ALWAYS AS ROW END   HIDDEN NOT NULL,
    PERIOD FOR SYSTEM_TIME (SysStartTime, SysEndTime),
    CONSTRAINT PK_LoyaltyAccount PRIMARY KEY CLUSTERED (LoyaltyId),
    CONSTRAINT UQ_LoyaltyAccount_Customer UNIQUE (CustomerId),
    CONSTRAINT FK_LoyaltyAccount_Customer FOREIGN KEY (CustomerId) REFERENCES crm.Customer (CustomerId),
    CONSTRAINT FK_LoyaltyAccount_Tier FOREIGN KEY (TierId) REFERENCES loyalty.LoyaltyTier (TierId),
    CONSTRAINT CK_LoyaltyAccount_Balance CHECK (PointsBalance >= 0),
    CONSTRAINT CK_LoyaltyAccount_Status CHECK (Status IN (N'Active', N'Suspended', N'Closed'))
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = loyalty.LoyaltyAccountHistory));
GO

/* ---------- loyalty.LoyaltyTxn (append-only ledger) ---------- */
CREATE TABLE loyalty.LoyaltyTxn
(
    TxnId           BIGINT IDENTITY(1,1) NOT NULL,
    LoyaltyId       INT NOT NULL,
    OrderId         INT NULL,
    Type            NVARCHAR(10) NOT NULL,
    Points          INT NOT NULL,                -- positive = credit, negative = debit
    PointsRemaining INT NULL,                    -- EARN rows only: not yet redeemed/expired
    ExpiresOn       DATE NULL,                   -- EARN rows only
    Notes           NVARCHAR(200) NULL,
    CreatedAt       DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_LoyaltyTxn PRIMARY KEY CLUSTERED (TxnId),
    CONSTRAINT FK_LoyaltyTxn_Account FOREIGN KEY (LoyaltyId) REFERENCES loyalty.LoyaltyAccount (LoyaltyId),
    CONSTRAINT FK_LoyaltyTxn_Order FOREIGN KEY (OrderId) REFERENCES sales.SalesOrder (OrderId),
    CONSTRAINT CK_LoyaltyTxn_Type CHECK (Type IN (N'EARN', N'REDEEM', N'EXPIRE', N'ADJUST', N'REVERSAL')),
    CONSTRAINT CK_LoyaltyTxn_Sign CHECK (
           (Type = N'EARN' AND Points > 0)
        OR (Type IN (N'REDEEM', N'EXPIRE') AND Points < 0)
        OR (Type IN (N'ADJUST', N'REVERSAL') AND Points <> 0))
);
GO

/* ---------- loyalty.Reward ---------- */
CREATE TABLE loyalty.Reward
(
    RewardId   INT IDENTITY(1,1) NOT NULL,
    Name       NVARCHAR(150) NOT NULL,
    Description NVARCHAR(500) NULL,
    PointsCost INT NOT NULL,
    MinTierId  INT NULL,
    ValidFrom  DATE NULL,
    ValidTo    DATE NULL,
    StockQty   INT NULL,                         -- NULL = unlimited
    IsActive   BIT NOT NULL DEFAULT 1,
    CONSTRAINT PK_Reward PRIMARY KEY CLUSTERED (RewardId),
    CONSTRAINT FK_Reward_Tier FOREIGN KEY (MinTierId) REFERENCES loyalty.LoyaltyTier (TierId),
    CONSTRAINT CK_Reward_Values CHECK (PointsCost > 0 AND (StockQty IS NULL OR StockQty >= 0)),
    CONSTRAINT CK_Reward_Dates CHECK (ValidTo IS NULL OR ValidFrom IS NULL OR ValidTo >= ValidFrom)
);
GO

/* ---------- loyalty.RewardRedemption ---------- */
CREATE TABLE loyalty.RewardRedemption
(
    RedemptionId INT IDENTITY(1,1) NOT NULL,
    LoyaltyId    INT NOT NULL,
    RewardId     INT NOT NULL,
    TxnId        BIGINT NOT NULL,                -- ledger row that debited the points
    PointsSpent  INT NOT NULL,
    Status       NVARCHAR(10) NOT NULL DEFAULT N'Issued',
    RedeemedAt   DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_RewardRedemption PRIMARY KEY CLUSTERED (RedemptionId),
    CONSTRAINT FK_Redemption_Account FOREIGN KEY (LoyaltyId) REFERENCES loyalty.LoyaltyAccount (LoyaltyId),
    CONSTRAINT FK_Redemption_Reward FOREIGN KEY (RewardId) REFERENCES loyalty.Reward (RewardId),
    CONSTRAINT FK_Redemption_Txn FOREIGN KEY (TxnId) REFERENCES loyalty.LoyaltyTxn (TxnId),
    CONSTRAINT CK_Redemption_Status CHECK (Status IN (N'Issued', N'Used', N'Cancelled')),
    CONSTRAINT CK_Redemption_Points CHECK (PointsSpent > 0)
);
GO

/* ---------- marketing.Campaign ---------- */
CREATE TABLE marketing.Campaign
(
    CampaignId INT IDENTITY(1,1) NOT NULL,
    Name       NVARCHAR(150) NOT NULL,
    Channel    NVARCHAR(15) NOT NULL,
    StartDate  DATE NOT NULL,
    EndDate    DATE NULL,
    Budget     DECIMAL(18,2) NULL,
    Settings   NVARCHAR(MAX) NULL,               -- JSON: audience rules, templates...
    CreatedAt  DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Campaign PRIMARY KEY CLUSTERED (CampaignId),
    CONSTRAINT CK_Campaign_Channel CHECK (Channel IN (N'Email', N'SMS', N'WhatsApp', N'Phone', N'InStore')),
    CONSTRAINT CK_Campaign_Dates CHECK (EndDate IS NULL OR EndDate >= StartDate),
    CONSTRAINT CK_Campaign_Settings CHECK (Settings IS NULL OR ISJSON(Settings) = 1)
);
GO

/* ---------- marketing.CampaignMember ---------- */
CREATE TABLE marketing.CampaignMember
(
    CampaignId       INT NOT NULL,
    CustomerId       INT NOT NULL,
    SentAt           DATETIME2(0) NULL,
    Response         NVARCHAR(10) NOT NULL DEFAULT N'None',
    ConvertedOrderId INT NULL,
    CONSTRAINT PK_CampaignMember PRIMARY KEY CLUSTERED (CampaignId, CustomerId),
    CONSTRAINT FK_CampaignMember_Campaign FOREIGN KEY (CampaignId) REFERENCES marketing.Campaign (CampaignId),
    CONSTRAINT FK_CampaignMember_Customer FOREIGN KEY (CustomerId) REFERENCES crm.Customer (CustomerId),
    CONSTRAINT FK_CampaignMember_Order FOREIGN KEY (ConvertedOrderId) REFERENCES sales.SalesOrder (OrderId),
    CONSTRAINT CK_CampaignMember_Response CHECK (Response IN (N'None', N'Opened', N'Clicked', N'Converted', N'OptOut'))
);
GO

/* ---------- marketing.SurveyResponse ---------- */
CREATE TABLE marketing.SurveyResponse
(
    SurveyId    INT IDENTITY(1,1) NOT NULL,
    CustomerId  INT NOT NULL,
    OrderId     INT NULL,
    TicketId    INT NULL,                        -- post-service survey
    NpsScore    TINYINT NOT NULL,
    Comment     NVARCHAR(1000) NULL,
    AnsweredAt  DATETIME2(0) NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_SurveyResponse PRIMARY KEY CLUSTERED (SurveyId),
    CONSTRAINT FK_Survey_Customer FOREIGN KEY (CustomerId) REFERENCES crm.Customer (CustomerId),
    CONSTRAINT FK_Survey_Order FOREIGN KEY (OrderId) REFERENCES sales.SalesOrder (OrderId),
    CONSTRAINT FK_Survey_Ticket FOREIGN KEY (TicketId) REFERENCES service.ServiceTicket (TicketId),
    CONSTRAINT CK_Survey_Nps CHECK (NpsScore BETWEEN 0 AND 10)
);
GO

/*---------------------------------------------------------------
  4. INDEXES  (beyond PK / UNIQUE constraints)
---------------------------------------------------------------*/
-- crm
CREATE UNIQUE INDEX UX_Customer_Code    ON crm.Customer (CustomerCode);
CREATE UNIQUE INDEX UX_Customer_Email   ON crm.Customer (Email)      WHERE Email IS NOT NULL;
CREATE UNIQUE INDEX UX_Customer_Nat     ON crm.Customer (NationalId) WHERE NationalId IS NOT NULL;
CREATE INDEX IX_Customer_Name           ON crm.Customer (FullName);
CREATE INDEX IX_Customer_Phone          ON crm.Customer (Phone)      WHERE Phone IS NOT NULL;
CREATE INDEX IX_Customer_Segment        ON crm.Customer (Segment)    WHERE IsActive = 1;
CREATE INDEX IX_Customer_ReferredBy     ON crm.Customer (ReferredByCustomerId) WHERE ReferredByCustomerId IS NOT NULL;
CREATE UNIQUE INDEX UX_Address_Default  ON crm.CustomerAddress (CustomerId) WHERE IsDefault = 1;
CREATE INDEX IX_Address_Customer        ON crm.CustomerAddress (CustomerId);
CREATE INDEX IX_Interaction_Customer    ON crm.Interaction (CustomerId, OccurredAt DESC) INCLUDE (Channel, Type);
-- sales
CREATE UNIQUE INDEX UX_Category_Name    ON sales.ProductCategory (ParentId, Name);
CREATE INDEX IX_Product_Category        ON sales.Product (CategoryId) INCLUDE (Sku, Name, ListPrice);
CREATE INDEX IX_Order_Customer          ON sales.SalesOrder (CustomerId, OrderDate DESC) INCLUDE (Status, Total);
CREATE UNIQUE INDEX UX_Order_Number     ON sales.SalesOrder (OrderNumber);
CREATE INDEX IX_Order_User              ON sales.SalesOrder (SoldByUserId) WHERE SoldByUserId IS NOT NULL;
CREATE INDEX IX_OrderLine_Order         ON sales.OrderLine (OrderId) INCLUDE (ProductId, ServiceId, Qty, LineTotal);
CREATE INDEX IX_OrderLine_Product       ON sales.OrderLine (ProductId) WHERE ProductId IS NOT NULL;
CREATE INDEX IX_Unit_OrderLine          ON sales.ProductUnit (OrderLineId) WHERE OrderLineId IS NOT NULL;
CREATE INDEX IX_Unit_Serial             ON sales.ProductUnit (SerialNumber);
CREATE INDEX IX_Payment_Order           ON sales.Payment (OrderId) INCLUDE (Amount, Status);
-- warranty
CREATE UNIQUE INDEX UX_Warranty_UnitPlan ON warranty.Warranty (UnitId, PlanId) WHERE Status <> N'Void';
CREATE INDEX IX_Warranty_Expiry         ON warranty.Warranty (EndDate) INCLUDE (UnitId, Status) WHERE Status = N'Active';
CREATE INDEX IX_Claim_Warranty          ON warranty.WarrantyClaim (WarrantyId);
CREATE INDEX IX_Claim_Pending           ON warranty.WarrantyClaim (ClaimDate) WHERE Decision = N'Pending';
-- service
CREATE UNIQUE INDEX UX_Ticket_Number    ON service.ServiceTicket (TicketNumber);
CREATE UNIQUE INDEX UX_Ticket_Claim     ON service.ServiceTicket (ClaimId) WHERE ClaimId IS NOT NULL;
CREATE INDEX IX_Ticket_Customer         ON service.ServiceTicket (CustomerId, OpenedAt DESC);
CREATE INDEX IX_Ticket_Open             ON service.ServiceTicket (AssignedUserId, DueAt) INCLUDE (Priority, Status)
                                        WHERE Status IN (N'Open', N'InProgress', N'OnHold');
CREATE INDEX IX_Ticket_Unit             ON service.ServiceTicket (UnitId) WHERE UnitId IS NOT NULL;
-- loyalty
CREATE INDEX IX_Account_Tier            ON loyalty.LoyaltyAccount (TierId);
CREATE INDEX IX_Txn_Account             ON loyalty.LoyaltyTxn (LoyaltyId, CreatedAt DESC) INCLUDE (Type, Points);
CREATE UNIQUE INDEX UX_Txn_OrderEarn    ON loyalty.LoyaltyTxn (OrderId) WHERE Type = N'EARN' AND OrderId IS NOT NULL;
CREATE INDEX IX_Txn_Fifo                ON loyalty.LoyaltyTxn (LoyaltyId, ExpiresOn, TxnId) INCLUDE (PointsRemaining)
                                        WHERE Type = N'EARN' AND PointsRemaining > 0;
CREATE INDEX IX_Txn_Expiry              ON loyalty.LoyaltyTxn (ExpiresOn) INCLUDE (LoyaltyId, PointsRemaining)
                                        WHERE Type = N'EARN' AND PointsRemaining > 0;
CREATE INDEX IX_Redemption_Account      ON loyalty.RewardRedemption (LoyaltyId, RedeemedAt DESC);
CREATE INDEX IX_Redemption_Reward       ON loyalty.RewardRedemption (RewardId);
-- marketing
CREATE INDEX IX_CampaignMember_Customer ON marketing.CampaignMember (CustomerId);
CREATE INDEX IX_Survey_Customer         ON marketing.SurveyResponse (CustomerId, AnsweredAt DESC) INCLUDE (NpsScore);
GO

/*---------------------------------------------------------------
  5. TRIGGERS
---------------------------------------------------------------*/

-- Keep SalesOrder.Total in sync with its lines
CREATE OR ALTER TRIGGER sales.trg_OrderLine_Total
ON sales.OrderLine
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE o
       SET Total     = ISNULL((SELECT SUM(l.LineTotal) FROM sales.OrderLine l WHERE l.OrderId = o.OrderId), 0),
           UpdatedAt = SYSUTCDATETIME()
      FROM sales.SalesOrder o
     WHERE o.OrderId IN (SELECT OrderId FROM inserted UNION SELECT OrderId FROM deleted);
END;
GO

-- A claim must fall inside the warranty coverage period
CREATE OR ALTER TRIGGER warranty.trg_WarrantyClaim_Coverage
ON warranty.WarrantyClaim
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1
                 FROM inserted i
                 JOIN warranty.Warranty w ON w.WarrantyId = i.WarrantyId
                WHERE w.Status = N'Void'
                   OR i.ClaimDate < w.StartDate
                   OR i.ClaimDate > w.EndDate)
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50020, N'Claim date is outside the warranty coverage period (or the warranty is void).', 1;
    END
END;
GO

/*---------------------------------------------------------------
  6. VIEWS
---------------------------------------------------------------*/

-- Warranties expiring in the next 60 days: feeds renewal / upsell campaigns
CREATE OR ALTER VIEW warranty.vExpiringWarranties
AS
SELECT  w.WarrantyId, w.UnitId, w.EndDate,
        DATEDIFF(DAY, CAST(SYSUTCDATETIME() AS DATE), w.EndDate) AS DaysLeft,
        u.SerialNumber, p.Sku, p.Name AS ProductName,
        c.CustomerId, c.CustomerCode, c.FullName, c.Email, c.Phone
FROM    warranty.Warranty w
JOIN    sales.ProductUnit u ON u.UnitId = w.UnitId
JOIN    sales.Product     p ON p.ProductId = u.ProductId
JOIN    sales.OrderLine   l ON l.OrderLineId = u.OrderLineId
JOIN    sales.SalesOrder  o ON o.OrderId = l.OrderId
JOIN    crm.Customer      c ON c.CustomerId = o.CustomerId
WHERE   w.Status = N'Active'
  AND   w.EndDate BETWEEN CAST(SYSUTCDATETIME() AS DATE)
                      AND DATEADD(DAY, 60, CAST(SYSUTCDATETIME() AS DATE));
GO

-- Customer 360 summary
CREATE OR ALTER VIEW crm.vCustomer360
AS
SELECT  c.CustomerId, c.CustomerCode, c.FullName, c.Segment,
        la.PointsBalance, lt.Name AS Tier,
        ord.OrderCount, ord.LifetimeValue, ord.LastOrderDate,
        tk.OpenTickets,
        nps.LastNps
FROM    crm.Customer c
LEFT JOIN loyalty.LoyaltyAccount la ON la.CustomerId = c.CustomerId
LEFT JOIN loyalty.LoyaltyTier    lt ON lt.TierId = la.TierId
OUTER APPLY (SELECT COUNT(*) AS OrderCount, SUM(o.Total) AS LifetimeValue, MAX(o.OrderDate) AS LastOrderDate
               FROM sales.SalesOrder o
              WHERE o.CustomerId = c.CustomerId AND o.Status = N'Completed') ord
OUTER APPLY (SELECT COUNT(*) AS OpenTickets
               FROM service.ServiceTicket t
              WHERE t.CustomerId = c.CustomerId
                AND t.Status IN (N'Open', N'InProgress', N'OnHold')) tk
OUTER APPLY (SELECT TOP (1) s.NpsScore AS LastNps
               FROM marketing.SurveyResponse s
              WHERE s.CustomerId = c.CustomerId
              ORDER BY s.AnsweredAt DESC) nps
WHERE   c.IsActive = 1;
GO

/*---------------------------------------------------------------
  7. STORED PROCEDURES
---------------------------------------------------------------*/

-- Enrol a customer in the loyalty program at the lowest tier
CREATE OR ALTER PROCEDURE loyalty.usp_EnrolCustomer
    @CustomerId INT,
    @LoyaltyId  INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    SELECT @LoyaltyId = LoyaltyId FROM loyalty.LoyaltyAccount WHERE CustomerId = @CustomerId;
    IF @LoyaltyId IS NOT NULL RETURN;

    DECLARE @TierId INT = (SELECT TOP (1) TierId FROM loyalty.LoyaltyTier ORDER BY MinPoints);
    IF @TierId IS NULL THROW 50030, N'No loyalty tiers are defined.', 1;

    INSERT loyalty.LoyaltyAccount (CustomerId, TierId) VALUES (@CustomerId, @TierId);
    SET @LoyaltyId = SCOPE_IDENTITY();
END;
GO

-- Earn points for a completed order (idempotent: one EARN row per order)
CREATE OR ALTER PROCEDURE loyalty.usp_EarnPointsForOrder
    @OrderId              INT,
    @PointsPerCurrencyUnit DECIMAL(9,4) = 0.01,   -- 0.01 = 1 point per 100 currency units
    @ExpiryMonths          INT = 24
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;

    DECLARE @CustomerId INT, @Total DECIMAL(18,2), @Status NVARCHAR(15);
    SELECT @CustomerId = CustomerId, @Total = Total, @Status = Status
      FROM sales.SalesOrder WHERE OrderId = @OrderId;

    IF @CustomerId IS NULL THROW 50031, N'Order not found.', 1;
    IF @Status <> N'Completed' THROW 50032, N'Only completed orders earn points.', 1;

    DECLARE @LoyaltyId INT, @Mult DECIMAL(5,2);
    SELECT @LoyaltyId = a.LoyaltyId, @Mult = t.PointsMultiplier
      FROM loyalty.LoyaltyAccount a
      JOIN loyalty.LoyaltyTier t ON t.TierId = a.TierId
     WHERE a.CustomerId = @CustomerId AND a.Status = N'Active';

    IF @LoyaltyId IS NULL RETURN;                                   -- not enrolled
    IF EXISTS (SELECT 1 FROM loyalty.LoyaltyTxn WHERE OrderId = @OrderId AND Type = N'EARN') RETURN;

    DECLARE @Pts INT = CAST(FLOOR(@Total * @PointsPerCurrencyUnit * @Mult) AS INT);
    IF @Pts <= 0 RETURN;

    BEGIN TRAN;
        INSERT loyalty.LoyaltyTxn (LoyaltyId, OrderId, Type, Points, PointsRemaining, ExpiresOn, Notes)
        VALUES (@LoyaltyId, @OrderId, N'EARN', @Pts, @Pts,
                DATEADD(MONTH, @ExpiryMonths, CAST(SYSUTCDATETIME() AS DATE)), N'Order purchase');

        UPDATE loyalty.LoyaltyAccount
           SET PointsBalance = PointsBalance + @Pts, UpdatedAt = SYSUTCDATETIME()
         WHERE LoyaltyId = @LoyaltyId;
    COMMIT;
END;
GO

-- Redeem a reward: validates tier, balance, stock and dates; consumes oldest points first
CREATE OR ALTER PROCEDURE loyalty.usp_RedeemReward
    @LoyaltyId    INT,
    @RewardId     INT,
    @RedemptionId INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @Today DATE = CAST(SYSUTCDATETIME() AS DATE);
    DECLARE @Balance INT, @TierMin INT, @Cost INT, @ReqMin INT, @Stock INT, @TxnId BIGINT;

    BEGIN TRAN;

    SELECT @Balance = a.PointsBalance, @TierMin = t.MinPoints
      FROM loyalty.LoyaltyAccount a WITH (UPDLOCK, HOLDLOCK)
      JOIN loyalty.LoyaltyTier t ON t.TierId = a.TierId
     WHERE a.LoyaltyId = @LoyaltyId AND a.Status = N'Active';
    IF @Balance IS NULL THROW 50040, N'Loyalty account not found or not active.', 1;

    SELECT @Cost = r.PointsCost, @Stock = r.StockQty, @ReqMin = ISNULL(rt.MinPoints, 0)
      FROM loyalty.Reward r WITH (UPDLOCK, HOLDLOCK)
      LEFT JOIN loyalty.LoyaltyTier rt ON rt.TierId = r.MinTierId
     WHERE r.RewardId = @RewardId AND r.IsActive = 1
       AND (r.ValidFrom IS NULL OR r.ValidFrom <= @Today)
       AND (r.ValidTo   IS NULL OR r.ValidTo   >= @Today);
    IF @Cost IS NULL           THROW 50041, N'Reward not available.', 1;
    IF @Stock = 0              THROW 50042, N'Reward is out of stock.', 1;
    IF @TierMin < @ReqMin      THROW 50043, N'Customer tier is too low for this reward.', 1;
    IF @Balance < @Cost        THROW 50044, N'Insufficient points.', 1;

    -- consume EARN buckets oldest-expiry first
    UPDATE t
       SET PointsRemaining = CASE WHEN e.Running <= @Cost THEN 0 ELSE e.Running - @Cost END
      FROM loyalty.LoyaltyTxn t
      JOIN (SELECT TxnId, PointsRemaining,
                   SUM(PointsRemaining) OVER (ORDER BY ExpiresOn, TxnId ROWS UNBOUNDED PRECEDING) AS Running
              FROM loyalty.LoyaltyTxn
             WHERE LoyaltyId = @LoyaltyId AND Type = N'EARN' AND PointsRemaining > 0) e
        ON e.TxnId = t.TxnId
     WHERE e.Running - e.PointsRemaining < @Cost;

    INSERT loyalty.LoyaltyTxn (LoyaltyId, Type, Points, Notes)
    VALUES (@LoyaltyId, N'REDEEM', -@Cost, CONCAT(N'Reward #', @RewardId));
    SET @TxnId = SCOPE_IDENTITY();

    UPDATE loyalty.LoyaltyAccount
       SET PointsBalance = PointsBalance - @Cost, UpdatedAt = SYSUTCDATETIME()
     WHERE LoyaltyId = @LoyaltyId;

    IF @Stock IS NOT NULL
        UPDATE loyalty.Reward SET StockQty = StockQty - 1 WHERE RewardId = @RewardId;

    INSERT loyalty.RewardRedemption (LoyaltyId, RewardId, TxnId, PointsSpent)
    VALUES (@LoyaltyId, @RewardId, @TxnId, @Cost);
    SET @RedemptionId = SCOPE_IDENTITY();

    COMMIT;
END;
GO

-- Nightly job: expire points past their ExpiresOn date
CREATE OR ALTER PROCEDURE loyalty.usp_ExpirePoints
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @Today DATE = CAST(SYSUTCDATETIME() AS DATE);

    CREATE TABLE #Expired (TxnId BIGINT PRIMARY KEY, LoyaltyId INT NOT NULL, Pts INT NOT NULL);

    BEGIN TRAN;

    INSERT #Expired (TxnId, LoyaltyId, Pts)
    SELECT TxnId, LoyaltyId, PointsRemaining
      FROM loyalty.LoyaltyTxn WITH (UPDLOCK)
     WHERE Type = N'EARN' AND PointsRemaining > 0 AND ExpiresOn < @Today;

    IF EXISTS (SELECT 1 FROM #Expired)
    BEGIN
        INSERT loyalty.LoyaltyTxn (LoyaltyId, Type, Points, Notes)
        SELECT LoyaltyId, N'EXPIRE', -SUM(Pts), N'Points expired'
          FROM #Expired GROUP BY LoyaltyId;

        UPDATE a
           SET PointsBalance = a.PointsBalance - x.Pts, UpdatedAt = SYSUTCDATETIME()
          FROM loyalty.LoyaltyAccount a
          JOIN (SELECT LoyaltyId, SUM(Pts) AS Pts FROM #Expired GROUP BY LoyaltyId) x
            ON x.LoyaltyId = a.LoyaltyId;

        UPDATE t SET PointsRemaining = 0
          FROM loyalty.LoyaltyTxn t JOIN #Expired e ON e.TxnId = t.TxnId;
    END

    COMMIT;
END;
GO

-- Nightly job: tier = highest tier reached by points EARNED in the last 12 months
CREATE OR ALTER PROCEDURE loyalty.usp_RecalculateTiers
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE a
       SET TierId = t.TierId, UpdatedAt = SYSUTCDATETIME()
      FROM loyalty.LoyaltyAccount a
     OUTER APPLY (SELECT ISNULL(SUM(x.Points), 0) AS Pts
                    FROM loyalty.LoyaltyTxn x
                   WHERE x.LoyaltyId = a.LoyaltyId AND x.Type = N'EARN'
                     AND x.CreatedAt >= DATEADD(YEAR, -1, SYSUTCDATETIME())) e
     CROSS APPLY (SELECT TOP (1) TierId FROM loyalty.LoyaltyTier
                   WHERE MinPoints <= e.Pts ORDER BY MinPoints DESC) t
     WHERE a.Status = N'Active' AND a.TierId <> t.TierId;
END;
GO

-- Register a warranty for a sold unit (standard = product default months; extended = chosen plan)
CREATE OR ALTER PROCEDURE warranty.usp_RegisterWarranty
    @UnitId     INT,
    @PlanId     INT  = NULL,
    @StartDate  DATE = NULL,
    @WarrantyId INT  = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    DECLARE @SoldOn DATE, @Months INT, @Plan INT = @PlanId, @Found INT = 0;

    SELECT @SoldOn = u.SoldOn, @Months = p.DefaultWarrantyMonths, @Found = 1
      FROM sales.ProductUnit u
      JOIN sales.Product p ON p.ProductId = u.ProductId
     WHERE u.UnitId = @UnitId;

    IF @Found = 0       THROW 50050, N'Unit not found.', 1;
    IF @SoldOn IS NULL  THROW 50051, N'Unit has not been sold.', 1;

    IF @Plan IS NULL
        SELECT @Plan = PlanId FROM warranty.WarrantyPlan WHERE PlanCode = N'STD';
    ELSE
    BEGIN
        SET @Months = NULL;
        SELECT @Months = DurationMonths FROM warranty.WarrantyPlan WHERE PlanId = @Plan AND IsActive = 1;
    END

    IF @Plan IS NULL OR @Months IS NULL OR @Months <= 0
        THROW 50052, N'Warranty plan not found, inactive, or product has no default warranty.', 1;

    -- extended coverage begins when current coverage ends
    IF @StartDate IS NULL
        SELECT @StartDate = ISNULL(MAX(EndDate), @SoldOn)
          FROM warranty.Warranty WHERE UnitId = @UnitId AND Status IN (N'Active', N'Pending');

    INSERT warranty.Warranty (UnitId, PlanId, StartDate, DurationMonths, Status)
    VALUES (@UnitId, @Plan, @StartDate, @Months,
            CASE WHEN @StartDate > CAST(SYSUTCDATETIME() AS DATE) THEN N'Pending' ELSE N'Active' END);
    SET @WarrantyId = SCOPE_IDENTITY();
END;
GO

-- Nightly job: activate pending and expire finished warranties
CREATE OR ALTER PROCEDURE warranty.usp_RefreshWarrantyStatus
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Today DATE = CAST(SYSUTCDATETIME() AS DATE);
    UPDATE warranty.Warranty SET Status = N'Active'  WHERE Status = N'Pending' AND StartDate <= @Today AND EndDate >= @Today;
    UPDATE warranty.Warranty SET Status = N'Expired' WHERE Status IN (N'Active', N'Pending') AND EndDate < @Today;
END;
GO

/*---------------------------------------------------------------
  8. SEED DATA (reference data only)
---------------------------------------------------------------*/
IF NOT EXISTS (SELECT 1 FROM loyalty.LoyaltyTier)
    INSERT loyalty.LoyaltyTier (Name, MinPoints, PointsMultiplier, Perks) VALUES
        (N'Bronze',       0, 1.00, N'Welcome benefits'),
        (N'Silver',     500, 1.25, N'Birthday bonus, priority support'),
        (N'Gold',      2000, 1.50, N'Free pickup service, extended-warranty discount'),
        (N'Platinum',  5000, 2.00, N'Dedicated advisor, annual free service');

IF NOT EXISTS (SELECT 1 FROM warranty.WarrantyPlan)
    INSERT warranty.WarrantyPlan (PlanCode, Name, PlanType, DurationMonths, Coverage, Price) VALUES
        (N'STD',   N'Standard manufacturer warranty', N'Standard', 12, N'Manufacturing defects (parts and labour)', 0),
        (N'EXT12', N'Extended warranty +12 months',   N'Extended', 12, N'Parts and labour, one pickup included', 0),
        (N'EXT24', N'Extended warranty +24 months',   N'Extended', 24, N'Parts and labour, pickups included', 0);

IF NOT EXISTS (SELECT 1 FROM sales.ServiceCatalog)
    INSERT sales.ServiceCatalog (ServiceCode, Name, StdPrice, IsRecurring, SlaHours) VALUES
        (N'WARRANTY-REPAIR', N'Warranty repair',          0,   0, 72),
        (N'PAID-REPAIR',     N'Paid repair',              0,   0, 72),
        (N'INSTALL',         N'Installation',             0,   0, 48),
        (N'MAINT-ANNUAL',    N'Annual maintenance plan',  0,   1, 96),
        (N'SUPPORT',         N'Customer support request', 0,   0, 24);

IF NOT EXISTS (SELECT 1 FROM sales.ProductCategory)
    INSERT sales.ProductCategory (ParentId, Name) VALUES (NULL, N'General');
GO

/*---------------------------------------------------------------
  9. SECURITY (database roles; map real logins/users to them)
---------------------------------------------------------------*/
IF DATABASE_PRINCIPAL_ID(N'crm_admin')     IS NULL CREATE ROLE crm_admin;
IF DATABASE_PRINCIPAL_ID(N'crm_sales')     IS NULL CREATE ROLE crm_sales;
IF DATABASE_PRINCIPAL_ID(N'crm_service')   IS NULL CREATE ROLE crm_service;
IF DATABASE_PRINCIPAL_ID(N'crm_marketing') IS NULL CREATE ROLE crm_marketing;
GO

-- The application should call procedures for loyalty and warranty changes
GRANT EXECUTE ON SCHEMA::loyalty  TO crm_sales, crm_admin;
GRANT EXECUTE ON SCHEMA::warranty TO crm_sales, crm_service, crm_admin;

GRANT SELECT, INSERT, UPDATE ON SCHEMA::crm       TO crm_sales, crm_admin;
GRANT SELECT, INSERT, UPDATE ON SCHEMA::sales     TO crm_sales, crm_admin;
GRANT SELECT ON SCHEMA::loyalty                   TO crm_sales, crm_service, crm_marketing, crm_admin;
GRANT SELECT ON SCHEMA::warranty                  TO crm_sales, crm_service, crm_marketing, crm_admin;
GRANT SELECT, INSERT, UPDATE ON SCHEMA::service   TO crm_service, crm_admin;
GRANT SELECT, INSERT, UPDATE ON SCHEMA::marketing TO crm_marketing, crm_admin;
GRANT SELECT ON SCHEMA::crm                       TO crm_service, crm_marketing;
GRANT SELECT ON SCHEMA::sales                     TO crm_service, crm_marketing;
-- Only admins may see unmasked email/phone
-- (all other roles get masked values because they lack UNMASK)
GRANT UNMASK TO crm_admin;
GO

/* ---- Optional: Row-Level Security so sales reps only see their own orders ----
   Uncomment after you map each database user name to sec.AppUser.Username.

CREATE FUNCTION sec.fn_OrderAccess(@SoldByUserId INT)
RETURNS TABLE WITH SCHEMABINDING
AS RETURN
    SELECT 1 AS Allowed
      FROM sec.AppUser u
     WHERE (u.UserId = @SoldByUserId AND u.Username = USER_NAME())
        OR IS_MEMBER(N'crm_admin') = 1;
GO
CREATE SECURITY POLICY sec.OrderPolicy
    ADD FILTER PREDICATE sec.fn_OrderAccess(SoldByUserId) ON sales.SalesOrder
    WITH (STATE = ON);
GO
*/

/*---------------------------------------------------------------
  QUICK SMOKE TEST (optional)
-----------------------------------------------------------------
DECLARE @c INT, @l INT, @o INT, @u INT, @w INT;
INSERT crm.Customer (FullName, Email, Phone) VALUES (N'Test Customer', N'test@example.com', N'809-555-0100');
SET @c = SCOPE_IDENTITY();
EXEC loyalty.usp_EnrolCustomer @CustomerId = @c, @LoyaltyId = @l OUTPUT;

INSERT sales.Product (CategoryId, Sku, Name, ListPrice, DefaultWarrantyMonths)
VALUES (1, N'TV-55', N'Smart TV 55"', 25000, 12);
INSERT sales.SalesOrder (CustomerId, Status) VALUES (@c, N'Draft');
SET @o = SCOPE_IDENTITY();
INSERT sales.OrderLine (OrderId, ProductId, Qty, UnitPrice) VALUES (@o, 1, 1, 25000);
INSERT sales.ProductUnit (ProductId, OrderLineId, SerialNumber, Status, SoldOn)
VALUES (1, SCOPE_IDENTITY(), N'SN-0001', N'Sold', CAST(SYSUTCDATETIME() AS DATE));
SET @u = SCOPE_IDENTITY();

UPDATE sales.SalesOrder SET Status = N'Completed' WHERE OrderId = @o;
EXEC warranty.usp_RegisterWarranty @UnitId = @u, @WarrantyId = @w OUTPUT;
EXEC loyalty.usp_EarnPointsForOrder @OrderId = @o;
SELECT * FROM crm.vCustomer360 WHERE CustomerId = @c;
---------------------------------------------------------------*/
