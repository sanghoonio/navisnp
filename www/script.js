// gives shiny rsid input
document.addEventListener('DOMContentLoaded', function () {
  const rsid_btn = document.getElementById('submit_rsid');
  
  rsid_btn.addEventListener('click', function() {
    let rsid_input = document.getElementById('rsid_input');
    var rsid = rsid_input.value;
    console.log(rsid)
    
    if (rsid != '') {
      Shiny.setInputValue('rsid', rsid);
    }    
  });
  
});