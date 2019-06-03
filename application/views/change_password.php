
<!------ Include the above in your HEAD tag ---------->

<div>
<div id="regContainer" class="container">
    <div class="row">
        <div class="col-md-6 col-md-offset-3">
            <div class="panel panel-login">
                <div class="panel-heading">
                    <div class="row">
                        <div class="col-md-12">
                            <a href="#" class="active" id="login-form-link">Change Password</a>
                        </div>
<!--                        <div class="col-xs-6">
                            <a href="#" class="active"  id="register-form-link">Register</a>
                        </div>-->
                    </div>
                    <hr>
                </div>
             
		<!--  Error -Success Messages -->
					<div class="row">
						<div class="col-md-12">
							<?php
								$this->load->helper('form');
								$error_msg = $this->session->flashdata('error');
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
							<?php } ?>
							
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
                           <form id="chapass-form" action="<?php echo base_url(); ?>user/change_password/<?php echo $this->uri->segment(3); ?>" method="post" role="form" style="display: block;">
                               <input type="hidden" name="key" id="key" value="<?php echo $this->uri->segment(3); ?>"/>
                                <div class="form-group">
                                    <label for="username"></label>
                                    <input type="password" name="new_password" id="new_password" tabindex="1" class="form-control" placeholder="Enter new password" value="" required="">
                                </div>
                                <div class="form-group">
                                    
                                    <input type="password" name="confirm_password" id="confirm_password" tabindex="2" class="form-control" placeholder="Enter Confirm Password" required="">
                                </div>
                                
                                <div class="form-group">
                                    <div class="row">
                                        <div class="col-sm-6 col-sm-offset-3">
                                            <input type="submit" name="changepass-submit" id="changepass-submit" tabindex="4" class="form-control btn btn-login" value="Change">
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
