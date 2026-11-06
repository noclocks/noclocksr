# Configurations

## Auth0 JWT requests

`get_auth0_jwt()` reads the `auth0` section of `config::get()`, or accepts an
explicit configuration list with `jwt_url`, `client_id`, `client_secret`,
`audience`, and `grant_type`. Existing lists with those fields remain supported.
The token endpoint must use HTTPS, and every field must be a non-empty string.

Copy `auth0-jwt.template.yml` to the ignored project-root `config.yml`, or merge
its `auth0` section into an existing configuration. Populate `AUTH0_JWT_URL`,
`AUTH0_CLIENT_ID`, `AUTH0_CLIENT_SECRET`, and `AUTH0_AUDIENCE` through your secret
manager or deployment environment. The template uses the `client_credentials`
grant. Do not commit populated configuration, environment files, or tokens.

The separate `auth0.yml` template uses a different configuration structure and
does not supply the fields required by `get_auth0_jwt()`.

Source cleanup does not invalidate previously exposed secrets. Before rotating
an application secret in Auth0, inventory its consumers and arrange secure
configuration updates. After rotation, verify token issuance with the replacement
and rejection of the old secret after propagation. Previously issued access
tokens require a separate containment assessment until they expire.

## Integrations

- Slack:
  - Webhook URL
  - Channel ID
  - User ID
  - App Manifest(s)
- Toggl:
  - API Token
  - Workspace ID
  - Project ID
  - Task ID
  - User ID
- Todoist:
  - API Token
  - Project ID
  - Task ID
- Raindrop.io:
  - API Token
  - Collection ID
  - Bookmark ID
- Resend:
  - API:
    - API Key
    - API Secret
  - SMTP:
    - SMTP Host
    - SMTP Port
    - SMTP User
    - SMTP Password
- GitHub:
  - Personal Access Token
- Supabase:
  - Project ID
  - API:
    - ANON API Secret
    - Service Role Key
  - Database:
    - URL
    - Host
    - Port
    - User
    - Password
    - Database Name
    - SSL Mode
- Keeper Password Manager:
  - Server
  - User
  - Password
  - Private Key
  - Device Token
- Google Cloud Platform:
  - Project ID
  - API Key
  - OAuth Client Credentials
  - Service Account Credentials
  - APIs:
    - Authentication
    - IAM
    - Compute Engine
    - Cloud Run
    - Cloud Build
    - Storage
    - Scheduler
    - Secret Manager
    - Pub/Sub
    - Maps APIs
- Google Workspace:
  - Google Mail (gmail)
  - Google Drive (gdrive)
  - Google Calendar (gcal)
  - Google Sheets (gsheets)
  - Google Docs (gdocs)
  - Google Meet (gmeet)
  - Google Contacts (People API)
  - Google Tasks
- Google Marketing Platform:
  - Google My Business Profile:
    - API Key
    - Location ID
  - Google Tag Manager:
    - Container ID
  - Google Ads:
    - Customer ID
  - Google Search Console:
    - Property ID
  - Google Analytics:
    - Tracking ID
- Brandfetch:
  - API Key
- RemoveBG:
  - API Key
- Real Favicon Generator:
  - API Key

