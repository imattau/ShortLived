# NIPs coverage

## Implemented (MVP)

* **NIP-94** File Metadata (client uses tags on kind:1)

  * Example tags:

    ```
    ["t","video/mp4"]
    ["url","https://…/v.mp4"]
    ["dim","1080x1920"]
    ["dur","21.4"]
    ["thumb","https://…/v.jpg"]
    ```
* **NIP-96** HTTP File Upload

  * Client posts multipart → expects JSON with URL/thumb/mime/dim/dur
* **NIP-57** Zaps

  * Builds wallet deep link (`lightning:`), listens for **9735** receipts
* **NIP-51** Lists

  * Client-side mutes/follows (mutes applied to feed)

## Planned / later

* NIP-53 Live events (live video)
* NIP-05 Names (identity labels)
* NIP-65 Relay list event (user-managed relay sets)
* NIP-98 HTTP Auth (for upload endpoints that require signed auth)
