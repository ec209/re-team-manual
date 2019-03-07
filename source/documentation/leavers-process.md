## Leavers Process

Each team is responsible for completing the work to remove and revoke a user when they have left the programme.  This work __*must*__ be completed as soon as they have left and takes first priority over other work.

Currently this is an involved process as there are several things that need to happen.

The team that is completing the leavers ticket is also responsible for notifying other programmes and teams where that person has worked.

### Pre-requisites

1. Create a story to track the process of the work within your team
2. Ensure that a leavers ticket has been opened and completed by the GDS IT Helpdesk
3. Where relevant inform other programmes via their second line support so that they can also process a leavers ticket

### Essential tasks

1. Remove access to the alphagov organisation on GitHub and any other relevant github organisations such as gds-operations, openregister, openregister-attic, ...
2. Remove access from any infrastructure providers e.g. AWS gds-users
3. Remove shell access from any infrastructure
4. Remove access from Docker Hub organisations such as openregister, gdsre, govukverify, ...
5. Remove access from credential stores
6. Remove access from any other systems that they had access to, once complete please add them to this list for others to make use of
7. If they have a GDS issued YubiKey it should be returned, wiped, placed in the safe, and the [spreadsheet](https://docs.google.com/spreadsheets/d/10ykIA656pnmkFTZsMfFb1eyWva0yKWOka9YxIVbhfo0/edit) updated.
