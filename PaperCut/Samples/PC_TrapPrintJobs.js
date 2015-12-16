/*
* Trap and warn users if they print known problem documents.
*
* Some organizations have known problem documents such as large
* spreadsheets that if accidentally printed will print thousands of
* pages.  This recipe will check for a known problem document
* and alert the user and ask them to confirm their actions.
*/
function printJobHook(inputs, actions) {
  
  var DOCUMENT_NAME = "Accounts.xlsx"; // The name of the problem document
  var LIMIT = 20;  // Define sane page count for the document
  
  /*
  * This print hook will need access to all job details
  * so return if full job analysis is not yet complete.
  * The only job details that are available before analysis
  * are metadata such as username, printer name, and date.
  *
  * See reference documentation for full explanation.
  */
  if (!inputs.job.isAnalysisComplete) {
    return;    // No job details yet so return.
  }
  
  if (inputs.job.documentName == DOCUMENT_NAME
      && inputs.job.totalPages > LIMIT) {
        
        var message = "<html><span style='font-size: 1.5em; color:red'>Printing"
            + inputs.job.documentName + " will print many pages.  Did you mean to"
            + " only print a range of pages?</span></html>";
        var response = actions.client.promptPrintCancel(message);
        if (response  == "CANCEL" || response  == "TIMEOUT") {
          // Cancel the job and exit the script.
          actions.job.cancel();
          return;
        }
        // User pressed OK, so allow it to print - simply continue taking no action.
      }
}
