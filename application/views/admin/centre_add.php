<!-- Content Wrapper. Contains page content -->
  <div class="content-wrapper">
    <!-- Content Header (Page header) -->
    <section class="content-header">
      <h1>
        Centre
      </h1>
      <!--<ol class="breadcrumb">
        <li><a href="#"><i class="fa fa-dashboard"></i> Home</a></li>
        <li><a href="#">Examples</a></li>
        <li class="active">Blank page</li>
      </ol>-->
    </section>

    <!-- Main content -->
    <section class="content">

      <!-- Default box -->
      <div class="box">
        <div class="box-header with-border">
          <h3 class="box-title">Add new Centre</h3>

          <div class="box-tools pull-right">
            
          </div>
        </div>
        <div class="box-body">
 
		<form method = "post" id="add_centre_form" class="add_centre_form form-horizontal cascde-forms" action = "<?php echo base_url(); ?>admin/centre/centre_add">			
       
  
              <!-- Date dd/mm/yyyy -->
              <div class="form-group">
                <label class="control-label col-sm-2">Title<span class="text-danger">*</span></label>

               <div class="col-sm-4">
					<input type="text" class="form-control  input-sm" autocomplete="off" required id="centre_name" name="centre_name" value="">
				</div>
              </div>
           
			  <div class="form-group">
                <label class="control-label col-sm-2">Centre Code<span class="text-danger">*</span></label>

               <div class="col-sm-4">
					<input type="text" class="form-control  input-sm" autocomplete="off" required  id="centre_code" name="centre_code" value="">
				</div>
              </div>
			  
			  <div class="form-group">
                <label class="control-label col-sm-2">Centre State<span class="text-danger">*</span></label>

               <div class="col-sm-4">
					<input type="text" class="form-control  input-sm" autocomplete="off" required id="centre_state" name="centre_state" value="">
				</div>
              </div>
			  
			  <div class="form-group">
                <label class="control-label col-sm-2">Centre City<span class="text-danger">*</span></label>

               <div class="col-sm-4">
					<input type="text" class="form-control  input-sm" autocomplete="off" required id="centre_city" name="centre_city" value="">
				</div>
              </div>
              
			  
			   <div class="form-group">
                <label class="control-label col-sm-2">Pincode<span class="text-danger">*</span></label>

               <div class="col-sm-4">
					<input type="text" class="form-control  input-sm" autocomplete="off" required id="pin_code" name="pin_code" value="">
				</div>
              </div>
			  
			  <div class="form-group">
				<label class="control-label col-sm-2">Centre Address<span class="text-danger">*</span></label>
				<div class="col-sm-4">
				  <textarea rows="3" class="form-control  input-sm" required name="centre_address" id="centre_address" ></textarea>
				</div>
			  </div>
			  
			  <div class="form-group">
				<label class="control-label col-sm-2">Contact Person<span class="text-danger">*</span></label>
				<div class="col-sm-4">
				  <input type="text" class="form-control  input-sm"  required id="contact_person" name="contact_person" autocomplete="off" value="">
				</div>
			  </div>
			  
			  <div class="form-group">
				<label class="control-label col-sm-2">Contact Email<span class="text-danger">*</span></label>
				<div class="col-sm-4">
				  <input type="text" class="form-control  input-sm"  required id="contact_email" name="contact_email" autocomplete="off" value="">
				</div>
			  </div>
			 
			 <div class="form-group">
				<label class="control-label col-sm-2">Contact Mobile<span class="text-danger">*</span></label>
				<div class="col-sm-4">
				  <input type="text" class="form-control  input-sm"  required id="contact_mobile" name="contact_mobile" autocomplete="off" value="">
				</div>
			  </div>
			  
			  <div class="form-group">
				<label class="control-label col-sm-2">Contact Phone<span class="text-danger">*</span></label>
				<div class="col-sm-4">
				  <input type="text" class="form-control  input-sm"  required id="contact_phone" name="contact_phone" autocomplete="off" value="">
				</div>
			  </div>
			  
			  <div class="form-group">
				<label class="control-label col-sm-2">User Name<span class="text-danger">*</span></label>
				<div class="col-sm-4">
					<input type="text" class="form-control input-sm" required id="user_name" name="user_name" autocomplete="off" value="" >
				</div> 
			 </div>
				
				<div class="form-group">
					<label class="control-label col-sm-2">Password<span class="text-danger">*</span></label>
					<div class="col-sm-4">
						<input type="password" class="form-control input-sm" required id="user_password" name="user_password"  autocomplete="off" value="" >
					</div> 
				</div>
				
				<div class="form-group">
					<label class="control-label col-sm-2">Confirm Password<span class="text-danger">*</span></label>
					<div class="col-sm-4">
						<input type="password" class="form-control input-sm" required id="temp_password" name="temp_password"  autocomplete="off" value="" >
					</div> 
				</div>
				
				  <div class="form-group">
					<label class="col-sm-3 control-label"></label>
					<div class="col-sm-7">
					
					  <button type="submit" class="btn btn-success btn-sm">Submit</button>
					  <a class="btn btn-danger btn-sm"  onclick="window.history.go(-1);"> Cancel</a> </div>
				</div>
			  
			  
        
            <!-- /.box-body -->

         
         
        </form>

		</div>
        <!-- /.box-body -->
        
        <!-- /.box-footer-->
      </div>
      <!-- /.box -->

    </section>
    <!-- /.content -->
  </div>
  <!-- /.content-wrapper -->

  