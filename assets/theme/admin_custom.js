$(document).ready(function() {

         $('#registeruserlist').DataTable({
           'paging'      : true,
           'lengthChange': true,
           'searching'   : true,
           'ordering'    : true,
           'info'        : true,
           'autoWidth'   : false,
           dom: 'Bfrtip',
        buttons: [
             'csv', 'excel'
        ]
         })


             
       
       
});