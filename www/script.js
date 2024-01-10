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

// selects random rsid
document.addEventListener('DOMContentLoaded', function () {
  const rsid_array = commonSNPs = [
    'rs53576', 'rs1815739', 'rs7412', 'rs429358', 'rs6152',
    'rs333', 'rs1800497', 'rs1805007', 'rs9939609', 'rs662799',
    'rs7495174', 'rs12913832', 'rs7903146', 'rs12255372', 'rs1799971',
    'rs17822931', 'rs4680', 'rs1333049', 'rs1051730', 'rs3750344',
    'rs4988235', 'rs1800407', 'rs1801253', 'rs1042713', 'rs1065852',
    'rs1801133', 'rs1801282', 'rs1805124', 'rs1805008', 'rs1805128',
    'rs1805129', 'rs1801131', 'rs1801132', 'rs2230199', 'rs4646903',
    'rs2241880', 'rs20417', 'rs662', 'rs1801252', 'rs4290270', 'rs4986893',
    'rs16944', 'rs174570', 'rs1805087', 'rs12904', 'rs6265', 'rs1800547',
    'rs6471883', 'rs3813867', 'rs9930506', 'rs1800955', 'rs11091046',
    'rs3813196', 'rs11614913', 'rs11655081', 'rs6983267', 'rs13281615',
    'rs1801136', 'rs10741657', 'rs11171739', 'rs1800498', 'rs1229984',
    'rs1800925', 'rs1801252', 'rs1554606', 'rs9930501', 'rs3761847',
    'rs1045642', 'rs6269', 'rs1801394', 'rs2283792', 'rs671',
    'rs4977574', 'rs2071427', 'rs4778138', 'rs1801725', 'rs1801390',
    'rs2070673', 'rs12203717', 'rs2072633', 'rs3135506', 'rs11125529',
    'rs25487', 'rs2069837', 'rs3775291', 'rs10811661', 'rs1006737',
    'rs2292239', 'rs1800469', 'rs712', 'rs9536314', 'rs1801177',
    'rs1208', 'rs2228570', 'rs2187668', 'rs1801058', 'rs1800734',
    'rs10770125', 'rs429358', 'rs776746', 'rs10499194', 'rs699',
    'rs1800401', 'rs4073', 'rs7538876', 'rs4994', 'rs3736228'
  ];
  const random_btn = document.getElementById('random_rsid');
  
  random_btn.addEventListener('click', function() {
    let rsid_input = document.getElementById('rsid_input');
    var rsid = rsid_array[Math.floor(Math.random() * rsid_array.length)];
    rsid_input.value = rsid;

    Shiny.setInputValue('rsid', rsid);
  });
  
});
