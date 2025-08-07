-- DROP TABLE IF EXISTS products;

-- Create table
CREATE TABLE products
(
    id SERIAL PRIMARY KEY,
    create_date TIMESTAMP NOT NULL default CURRENT_TIMESTAMP,
    created_by TEXT DEFAULT CURRENT_USER,
    Product_JSON JSONB
);

/*
a. Choose json if preserving the exact textual representation of the JSON, 
including whitespace and key order, is critical, and querying performance 
is not a primary concern.

b. Choose jsonb for most use cases where efficient querying, indexing, and 
data manipulation are important, even with the slight overhead during 
data insertion and the loss of exact textual formatting. jsonb is generally 
recommended for its superior performance in read-heavy scenarios and for 
leveraging PostgreSQL's powerful indexing capabilities.
*/

-- First insert
insert into public.products (Product_JSON) values ('{
    "ProdCode": "34409CFD-793B-4243-B4F5-C1D3608735B8",
    "ProdName": "Incredible Product",
    "RequiresAuth": true,
    "MainComposition": "Water",
    "Lab": {
        "Name": "Penn Riverstone",
        "Location": "Backyard",
        "Web": null,
        "Email": null
    },
    "Composition": ["2 hydrogen atoms", "1 oxygen atom", "Some mixing"]
}');

-- View contents
Select * From products;

-- View with JSON parsing
SELECT
    id,
    Product_JSON ->> 'ProdCode'        AS prod_code,
    Product_JSON ->> 'ProdName'        AS prod_name,
    (Product_JSON ->> 'RequiresAuth')::boolean AS requires_auth,
    Product_JSON ->> 'MainComposition' AS main_composition,
    -- This portion reads from the dictionary
    (Product_JSON -> 'Lab') ->> 'Name'     AS lab_name,
    (Product_JSON -> 'Lab') ->> 'Location' AS lab_location,
    (Product_JSON -> 'Lab') ->> 'Web'      AS lab_web,
    (Product_JSON -> 'Lab') ->> 'Email'    AS lab_email,
    -- This portion converts the array (or list) to a comma-separated string
    array_to_string(ARRAY(
        SELECT jsonb_array_elements_text(product_JSON -> 'Composition')
    ), ', ') AS composition
FROM products;


-- Performance tip
CREATE INDEX idx_prodcode ON products ((Product_JSON ->> 'ProdCode'));

-- Second insert
insert into public.products (Product_JSON) values ('{
    "ProdCode": "8B1E78F8-6252-435B-A801-2CC3C2E45F77",
    "ProdName": "Natural Material",
    "RequiresAuth": true,
    "MainComposition": "Wood",
    "Lab": {
        "Name": "Forest Corp",
        "Location": "Wilderness",
        "Web": null,
        "Email": null
    },
    "Composition": ["Cellulose", "Hemicellulose", "Lignin", "Earth"]
}');

-- View with JSON parsing and multiple rows for the array
SELECT
    id,
    Product_JSON ->> 'ProdCode'        AS prod_code,
    Product_JSON ->> 'ProdName'        AS prod_name,
    (Product_JSON ->> 'RequiresAuth')::boolean AS requires_auth,
    Product_JSON ->> 'MainComposition' AS main_composition,
    -- This portion reads from the dictionary
    (Product_JSON -> 'Lab') ->> 'Name'     AS lab_name,
    (Product_JSON -> 'Lab') ->> 'Location' AS lab_location,
    (Product_JSON -> 'Lab') ->> 'Web'      AS lab_web,
    (Product_JSON -> 'Lab') ->> 'Email'    AS lab_email,
    -- This portion converts the array (or list) to multiple rows
    jsonb_array_elements_text(Product_JSON -> 'Composition') AS composition_items
FROM products;