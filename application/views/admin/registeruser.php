<!-- Content Wrapper. Contains page content -->
<div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <section class="content-header">
      <h1>
       User
        <small>Register List</small>
      </h1>
      <!-- <ol class="breadcrumb">
        <li><a href="#"><i class="fa fa-dashboard"></i> Home</a></li>
        <li><a href="#">User</a></li>
        <li class="active">Register List</li>
      </ol> -->
    </section>

    <!-- Main content -->
    <section class="content">
      <!-- Default box -->
      <div class="box">
        <div class="box-header with-border">
          <h3 class="box-title">User</h3>

          <!-- <div class="box-tools pull-right">
            <button type="button" class="btn btn-box-tool" data-widget="collapse" data-toggle="tooltip"
                    title="Collapse">
              <i class="fa fa-minus"></i></button>
            <button type="button" class="btn btn-box-tool" data-widget="remove" data-toggle="tooltip" title="Remove">
              <i class="fa fa-times"></i></button>
          </div> -->
        </div>
        <div class="box-body">
        <div class="box-header">
              <h3 class="box-title"><i class="fa fa fa-sitemap"></i> Register User List</h3>
           
			<span class="pull-right" style="margin-right:50px;">
				  <!-- <a class="btn btn-success btn-sm text-white" href="<?php echo base_url(); ?>admin/centre/centre_add" ><i class="fa fa-plus"></i> Add New</a> -->
				  <!--<button class="btn btn-warning btn-sm text-white" >Import</button>
				  <button class="btn btn-info btn-sm text-white" >Export</button>-->
			</span>
			 </div>
			 
            <!-- /.box-header -->
            <div class="box-body">
			<div id="confirm-div"></div>
              <table id="registeruserlist" class="table table-bordered table-striped">
                <thead>
                <tr>
                  <th>Sr. No.</th>
                  <th>Name</th>
                  <th>Email Id</th>
                  <th>Contact No.</th>
                  <th>Gender</th>
                  <th>Birthday Date</th>
                  <th>Birth Time</th>
                  <th>Plan</th>
                  <th>Action</th>
                </tr>
                </thead>
				<tbody>
						<?php 
				$i = 1;
				foreach($userdetail as $r){ ?>
					<tr>
						<td><?php  echo $i++; ?></td>
						<td><?php  echo $r['FirstName']."  ".$r['LastName'] ; ?></td>
						<td><?php  echo $r['Email']; ?></td>
						<td><?php  echo $r['Mobile']; ?></td>
						<td><?php  echo $r['Gender']; ?></td>
						<td><?php  echo $r['BirthDate']; ?></td>
						<td><?php  echo $r['BirthTime']; ?></td>
            <td><?php if($r['UserSubscriptionId']==1){ echo "Free"; } elseif($r['UserSubscriptionId']==2){ echo "Subscription"; } else { echo "One Time Paid"; }; ?></td>
						<td>
							   <!-- <a class="btn-success btn-xs" href='<?php //echo base_url()."admin/centre/centre_view/".$r['centre_id'];?>'><i class="fa fa-eye"></i></a>
							   <a class="btn-primary btn-xs" href='<?php //echo base_url()."admin/centre/centre_edit/".$r['centre_id']; ?>'><i class="fa fa-pencil"></i></a> -->
							   <a class="btn-danger btn-xs delete-centre"  href='<?php echo base_url()."admin/register/delete_user/".$r['user_id']; ?>' onclick="return confirm('Are you sure you want to delete this item?');"><i class="fa fa-trash-o"></i></a>
			   
						</td>  
					
					</tr>
				<?php } ?>	
				</tbody>
			 </table>	
			</div>	
        </div>
        <!-- /.box-body -->
        <div class="box-footer">
         
        </div>
        <!-- /.box-footer-->
      </div>
      <!-- /.box -->

    </section>
    <!-- /.content -->
  </div>
  <!-- /.content-wrapper -->
  <script src="<?php echo get_assets_path(); ?>theme/bower_components/jquery/dist/jquery.min.js"></script>
<!-- <script>
$(function () {
   // $('#example1').DataTable()
    $('#example1').DataTable({
      'paging'      : true,
      'lengthChange': true,
      'searching'   : true,
      'ordering'    : true,
      'info'        : true,
      'autoWidth'   : false
    })
  });
  $('#example1').DataTable( {
        dom: 'Bfrtip',
        buttons: [
            'copy', 'csv', 'excel', 'pdf', 'print'
        ]
    } );
</script> -->
  