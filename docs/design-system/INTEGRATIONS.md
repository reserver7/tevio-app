# External Integration Adapters

External packages are never imported directly from feature pages unless the
integration is strictly domain-specific. Shared presentation behavior lives in
the design-system adapters below.

| Capability | Package | Tevio adapter | Feature responsibility |
| --- | --- | --- | --- |
| Remote images | `cached_network_image` | `TevioNetworkImage` | image URL and domain fallback copy |
| Dates | Flutter picker | `TevioDateField` | valid ranges and persisted value |
| Documents | viewer/launcher selected by feature | `TevioDocumentPreview` | file access and document type |
| Permissions | `permission_handler` | `TevioPermissionRequest` | request timing and platform permission call |
| Camera | `camera` / `image_picker` | feature capture flow | receipt/model recognition and OCR |
| Confirm actions | Flutter modal route | `TevioConfirmSheet` | action outcome and mutation |

Do not add an external package before a feature needs it. Add the adapter,
Catalog sample, widget test, Golden update, and dependency review in the same
change.

## Product behavior

- A permission explanation must not promise that the operating-system settings
  screen will open unless the feature actually opens it. Provide a truthful
  fallback such as direct input when it is available.
- A document preview renders metadata and the open action consistently; the
  feature remains responsible for authorization, download and viewer errors.
- A confirmation sheet returns `true` only after the explicit confirm action.
  Dismissal and cancellation are both non-confirming outcomes.
