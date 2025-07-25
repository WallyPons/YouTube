@echo off
COLOR 02

REM 1. Create Format files:
REM Create folder(s)
REM MD C:\BCP\StackOverflow2010\FormatFile
echo.Creating format files
echo.Start time: %TIME%
echo.
bcp [StackOverflow2010].[dbo].[Badges] format nul -f "C:\BCP\StackOverflow2010\FormatFile\dbo_Badges.fmt" -N -S"." -T
bcp [StackOverflow2010].[dbo].[Comments] format nul -f "C:\BCP\StackOverflow2010\FormatFile\dbo_Comments.fmt" -N -S"." -T
bcp [StackOverflow2010].[dbo].[LinkTypes] format nul -f "C:\BCP\StackOverflow2010\FormatFile\dbo_LinkTypes.fmt" -N -S"." -T
bcp [StackOverflow2010].[dbo].[PostLinks] format nul -f "C:\BCP\StackOverflow2010\FormatFile\dbo_PostLinks.fmt" -N -S"." -T
bcp [StackOverflow2010].[dbo].[Posts] format nul -f "C:\BCP\StackOverflow2010\FormatFile\dbo_Posts.fmt" -N -S"." -T
bcp [StackOverflow2010].[dbo].[PostTypes] format nul -f "C:\BCP\StackOverflow2010\FormatFile\dbo_PostTypes.fmt" -N -S"." -T
bcp [StackOverflow2010].[dbo].[Users] format nul -f "C:\BCP\StackOverflow2010\FormatFile\dbo_Users.fmt" -N -S"." -T
bcp [StackOverflow2010].[dbo].[Votes] format nul -f "C:\BCP\StackOverflow2010\FormatFile\dbo_Votes.fmt" -N -S"." -T
bcp [StackOverflow2010].[dbo].[VoteTypes] format nul -f "C:\BCP\StackOverflow2010\FormatFile\dbo_VoteTypes.fmt" -N -S"." -T
echo.Created format files
echo.Completion time: %TIME%
echo.
REM pause

REM 2. Export BCP files:
REM Create folder(s)
REM MD C:\BCP\StackOverflow2010\QueryOut
REM MD C:\BCP\StackOverflow2010\Log\Out
echo.Exporting BCP files
echo.Start time: %TIME%
echo.
bcp "Select [Id],[Name],[UserId],[Date] From [StackOverflow2010].[dbo].[Badges] WITH (NOLOCK)" queryout "C:\BCP\StackOverflow2010\QueryOut\dbo_Badges.dat" -f "C:\BCP\StackOverflow2010\FormatFile\dbo_Badges.fmt" -o "C:\BCP\StackOverflow2010\Log\Out\dbo_Badges.log" -N -S"." -T
bcp "Select [Id],[CreationDate],[PostId],[Score],[Text],[UserId] From [StackOverflow2010].[dbo].[Comments] WITH (NOLOCK)" queryout "C:\BCP\StackOverflow2010\QueryOut\dbo_Comments.dat" -f "C:\BCP\StackOverflow2010\FormatFile\dbo_Comments.fmt" -o "C:\BCP\StackOverflow2010\Log\Out\dbo_Comments.log" -N -S"." -T
bcp "Select [Id],[Type] From [StackOverflow2010].[dbo].[LinkTypes] WITH (NOLOCK)" queryout "C:\BCP\StackOverflow2010\QueryOut\dbo_LinkTypes.dat" -f "C:\BCP\StackOverflow2010\FormatFile\dbo_LinkTypes.fmt" -o "C:\BCP\StackOverflow2010\Log\Out\dbo_LinkTypes.log" -N -S"." -T
bcp "Select [Id],[CreationDate],[PostId],[RelatedPostId],[LinkTypeId] From [StackOverflow2010].[dbo].[PostLinks] WITH (NOLOCK)" queryout "C:\BCP\StackOverflow2010\QueryOut\dbo_PostLinks.dat" -f "C:\BCP\StackOverflow2010\FormatFile\dbo_PostLinks.fmt" -o "C:\BCP\StackOverflow2010\Log\Out\dbo_PostLinks.log" -N -S"." -T
bcp "Select [Id],[AcceptedAnswerId],[AnswerCount],[Body],[ClosedDate],[CommentCount],[CommunityOwnedDate],[CreationDate],[FavoriteCount],[LastActivityDate],[LastEditDate],[LastEditorDisplayName],[LastEditorUserId],[OwnerUserId],[ParentId],[PostTypeId],[Score],[Tags],[Title],[ViewCount] From [StackOverflow2010].[dbo].[Posts] WITH (NOLOCK)" queryout "C:\BCP\StackOverflow2010\QueryOut\dbo_Posts.dat" -f "C:\BCP\StackOverflow2010\FormatFile\dbo_Posts.fmt" -o "C:\BCP\StackOverflow2010\Log\Out\dbo_Posts.log" -N -S"." -T
bcp "Select [Id],[Type] From [StackOverflow2010].[dbo].[PostTypes] WITH (NOLOCK)" queryout "C:\BCP\StackOverflow2010\QueryOut\dbo_PostTypes.dat" -f "C:\BCP\StackOverflow2010\FormatFile\dbo_PostTypes.fmt" -o "C:\BCP\StackOverflow2010\Log\Out\dbo_PostTypes.log" -N -S"." -T
bcp "Select [Id],[AboutMe],[Age],[CreationDate],[DisplayName],[DownVotes],[EmailHash],[LastAccessDate],[Location],[Reputation],[UpVotes],[Views],[WebsiteUrl],[AccountId] From [StackOverflow2010].[dbo].[Users] WITH (NOLOCK)" queryout "C:\BCP\StackOverflow2010\QueryOut\dbo_Users.dat" -f "C:\BCP\StackOverflow2010\FormatFile\dbo_Users.fmt" -o "C:\BCP\StackOverflow2010\Log\Out\dbo_Users.log" -N -S"." -T
bcp "Select [Id],[PostId],[UserId],[BountyAmount],[VoteTypeId],[CreationDate] From [StackOverflow2010].[dbo].[Votes] WITH (NOLOCK)" queryout "C:\BCP\StackOverflow2010\QueryOut\dbo_Votes.dat" -f "C:\BCP\StackOverflow2010\FormatFile\dbo_Votes.fmt" -o "C:\BCP\StackOverflow2010\Log\Out\dbo_Votes.log" -N -S"." -T
bcp "Select [Id],[Name] From [StackOverflow2010].[dbo].[VoteTypes] WITH (NOLOCK)" queryout "C:\BCP\StackOverflow2010\QueryOut\dbo_VoteTypes.dat" -f "C:\BCP\StackOverflow2010\FormatFile\dbo_VoteTypes.fmt" -o "C:\BCP\StackOverflow2010\Log\Out\dbo_VoteTypes.log" -N -S"." -T
echo.Exported BCP files
echo.Completion time: %TIME%
echo.
REM pause

REM 3. Import BCP files to new DB:
REM MD C:\BCP\StackOverflow2010\Log\In
echo.Importing BCP files
echo.Start time: %TIME%
echo.
bcp [StackOverflow2010New].[dbo].[Badges] in "C:\BCP\StackOverflow2010\QueryOut\dbo_Badges.dat" -f "C:\BCP\StackOverflow2010\FormatFile\dbo_Badges.fmt" -o "C:\BCP\StackOverflow2010\Log\In\dbo_Badges.log" -N -E -b 100000 -S"." -T
bcp [StackOverflow2010New].[dbo].[Comments] in "C:\BCP\StackOverflow2010\QueryOut\dbo_Comments.dat" -f "C:\BCP\StackOverflow2010\FormatFile\dbo_Comments.fmt" -o "C:\BCP\StackOverflow2010\Log\In\dbo_Comments.log" -N -E -b 100000 -S"." -T
bcp [StackOverflow2010New].[dbo].[LinkTypes] in "C:\BCP\StackOverflow2010\QueryOut\dbo_LinkTypes.dat" -f "C:\BCP\StackOverflow2010\FormatFile\dbo_LinkTypes.fmt" -o "C:\BCP\StackOverflow2010\Log\In\dbo_LinkTypes.log" -N -E -b 100000 -S"." -T
bcp [StackOverflow2010New].[dbo].[PostLinks] in "C:\BCP\StackOverflow2010\QueryOut\dbo_PostLinks.dat" -f "C:\BCP\StackOverflow2010\FormatFile\dbo_PostLinks.fmt" -o "C:\BCP\StackOverflow2010\Log\In\dbo_PostLinks.log" -N -E -b 100000 -S"." -T
bcp [StackOverflow2010New].[dbo].[Posts] in "C:\BCP\StackOverflow2010\QueryOut\dbo_Posts.dat" -f "C:\BCP\StackOverflow2010\FormatFile\dbo_Posts.fmt" -o "C:\BCP\StackOverflow2010\Log\In\dbo_Posts.log" -N -E -b 100000 -S"." -T
bcp [StackOverflow2010New].[dbo].[PostTypes] in "C:\BCP\StackOverflow2010\QueryOut\dbo_PostTypes.dat" -f "C:\BCP\StackOverflow2010\FormatFile\dbo_PostTypes.fmt" -o "C:\BCP\StackOverflow2010\Log\In\dbo_PostTypes.log" -N -E -b 100000 -S"." -T
bcp [StackOverflow2010New].[dbo].[Users] in "C:\BCP\StackOverflow2010\QueryOut\dbo_Users.dat" -f "C:\BCP\StackOverflow2010\FormatFile\dbo_Users.fmt" -o "C:\BCP\StackOverflow2010\Log\In\dbo_Users.log" -N -E -b 100000 -S"." -T
bcp [StackOverflow2010New].[dbo].[Votes] in "C:\BCP\StackOverflow2010\QueryOut\dbo_Votes.dat" -f "C:\BCP\StackOverflow2010\FormatFile\dbo_Votes.fmt" -o "C:\BCP\StackOverflow2010\Log\In\dbo_Votes.log" -N -E -b 100000 -S"." -T
bcp [StackOverflow2010New].[dbo].[VoteTypes] in "C:\BCP\StackOverflow2010\QueryOut\dbo_VoteTypes.dat" -f "C:\BCP\StackOverflow2010\FormatFile\dbo_VoteTypes.fmt" -o "C:\BCP\StackOverflow2010\Log\In\dbo_VoteTypes.log" -N -E -b 100000 -S"." -T
echo.Imported BCP files to new database
echo.Completion time: %TIME%
echo.
echo.===================================================================
pause
