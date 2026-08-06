# Screen Coverage

The design system is the only presentation dependency for feature screens.
Each screen must cover the following states before release:

| Screen | Loading | Empty | Error/retry | Normal | Important state | Golden |
| --- | --- | --- | --- | --- | --- | --- |
| Home | yes | yes | yes | yes | urgent/processing | yes |
| Products | yes | yes | yes | yes | filter/sort | yes |
| Product detail | yes | missing product | yes | yes | urgent/action required | pending |
| Notifications | yes | yes | yes | yes | unread/read/swipe | pending |
| Registration | yes | validation | submit failure | success | processing | pending |
| Settings | no | no | no | yes | theme/notification controls | pending |

Golden files are added only after the corresponding state is deterministic and
does not depend on device storage, network, or clock time. Use provider
overrides in tests instead of bypassing the production UI.
