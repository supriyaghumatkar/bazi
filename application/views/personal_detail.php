

<!------ Include the above in your HEAD tag ---------->

<div class="minheight">
<div id="regContainer" class="container">
    <div style="float: right">  <?php if($this->session->userdata('IsLogin')!=true){?>
    <a href="<?php echo base_url() ?>user" style="float: right">Login</a>
        <?php } else { ?>
     <a href="<?php echo base_url() ?>user/logout" style="float: right">Logout</a>
<?php }?></div>
    <?php
if(!empty($userdetail)) 
{
extract($userdetail);
}

?>
    <div class="row">
        <div class="col-md-6 col-md-offset-3 col-xs-10 col-xs-offset-1">
            <div class="panel panel-login">
                <div class="panel-heading">
                    <div class="row">

                        <div class="col-md-12">
                            <a href="#" class="active"  id="register-form-link">Enter Detail</a>
                          
                        </div>
                      
                    </div>
                    <hr>
                </div>
               
		<!--  Error -Success Messages -->
					<div class="row">
						<div class="col-md-12">
							<?php
							/*	$this->load->helper('form');
								$error_msg1 = $this->session->flashdata('error');
								if($error_msg)
								{
							?>
							<div class="alert alert-danger alert-dismissable">
								<button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>
								<?php echo $this->session->flashdata('error'); ?>                    
							</div>
							<?php } ?>
							<?php 
								
								$success_msg = $this->session->flashdata('success');
								if($success_msg)
								{
							?>
							<div class="alert alert-success alert-dismissable">
								<button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>
								<?php echo $this->session->flashdata('success'); ?>
							</div>
							<?php }*/ ?>
							
							<div class="row">
								<div class="col-md-12">
									<?php echo validation_errors('<div class="alert alert-danger alert-dismissable">', ' <button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button></div>'); ?>
								</div>
							</div>
						</div>
					</div>							
				<!--  /Error -Success Messages -->
                <div class="panel-body">
                    <div class="row">
                        <div class="col-lg-12">
                            <form id="personaldetail-form" action="<?php echo base_url(); ?>chart/fensui_chart_personal_detail" method="post" role="form">
                                <div class="form-group">
                                    <label for="firstname">First Name<span class="astrik">*</span></label>
                                    <input type="text" name="first_name" <?php if(!empty($userdetail)){ ?> value="<?php echo $FirstName;  ?>" <?php } ?> id="first_name" tabindex="1" class="form-control" placeholder="Enter Your First Name" value="" required="">
                                </div>
                                <div class="form-group">
                                    <label for="lastname">Last Name<span class="astrik">*</span></label>
                                    <input type="text" name="last_name" <?php if(!empty($userdetail)){ ?> value="<?php echo $LastName;  ?>" <?php } ?> id="last_name" tabindex="1" class="form-control" placeholder="Enter Your Last Name" value="" required=""> 
                                </div>
                                
                                <div class="form-group">
                                    <label for="gender">Gender<span class="astrik">*</span></label>
                                    <select name="gender" id="gender" tabindex="2" class="form-control" placeholder="Gender" required="">
                                        <option value="">Select Gender</option>
                                        <?php if(!empty($userdetail)){ ?> 
                                        <option value="Female" <?php if($Gender=='Female'){  ?> selected="selected" <?php } ?>>Female</option>
                                        <option value="Male" <?php if($Gender=='Male'){ ?> selected="selected" <?php } ?>>Male</option>
                                       <?php } else{ ?>
                                           <option value="Female">Female</option>
                                        <option value="Male">Male</option>
                                           <?php }?>
                                   </select>
                                </div>
                              <div class="form-group">
                                    <label for="lastname">Date Of Birth<span class="astrik">*</span></label>
                                    <input type="text" name="birttdate" <?php if(!empty($userdetail)){ ?> value="<?php echo $BirthDate;  ?>" <?php } ?> id="datepicker" tabindex="1" class="form-control date-picker" placeholder="mm/dd/yyyy" value="" required="">
                                </div>
                                 <div class="form-group">
                                    <label for="lastname">Birth Time</label>
                                    <input type="text" name="birthtime" value="02:25 PM" <?php if(!empty($userdetail)){ ?> value="<?php echo $BirthTime;  ?>" <?php } ?> id="timepicker2" tabindex="1" class="form-control timepicker1" placeholder="Select Time" value="">
                                </div>
                                <div class="form-group checkboxlabel">
                                    <label for="lastname">
                                    <input type="checkbox" name="DNbirthtime" id="DNbirthtime" tabindex="1"  class="form-control" value="NoTime">
                                    <span>Don't Know Birth Time</span></label>
                                </div>     
                                <div class="form-group">
                                    <div class="row">
                                        <div class="col-sm-6 col-sm-offset-3">
                                            <input type="submit" name="register-submit" id="register-submit" tabindex="4" class="form-control btn btn-register" value="Submit">
                                        </div>
                                    </div>
                                </div>

                               
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
</div>