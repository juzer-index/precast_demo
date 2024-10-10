# Go Cast Tracker Dependencies

- ElementMaster
   - BaQs
      - IIT_AllElement **to fetch the elements**
   - Tables
      - LotSelectUpdate  **to fetch the lots**
- stockLoading
   - BaQs
      - IIT_getDN2     **to fetch the reports**
      - IIT_DriverName  **to fetch the drivers**
      - IIT_UD103AutoGenerateNum_Test   **to fetch the last number**
   - Tables
      - ProjectSvc **to fetch the projects**
      - WarehseSvc **to fetch the warehouses**
      - WhseBinSvc **to fetch the bins**
      - LotSelectUpdateSvc **to fetch the lots**
      - UD104Svc **load header level**
      - UD104A   **load detail level**
      - UD102 **truck details**
- stockOffLoading
   - BaQs
      - IIT_getDN     **to fetch the reports**
   - Tables
      - LotSelectUpdateSvc **to fetch the lots**
      - UD104Svc **load header level**
      - UD104A   **load detail level**
      - UD102 **truck details**
## BPMs
-Data Directive on UD104A
-- IIT_MITPostLines
   **Conditions**: -  CheckBox01 = True
                   - CheckBox02 = True
                   - CheckBox03 = True
                   - CheckBox07 = false