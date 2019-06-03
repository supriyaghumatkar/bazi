
<!------ Include the above in your HEAD tag ---------->
<div class="minheight">
<div id="regContainer" class="container">
    <div class="row">
        <div class="col-md-6 col-xs-10  col-md-offset-3 col-xs-offset-1">
            <div class="panel panel-login">
                <div class="panel-heading">
                    <div class="row">
                        <!--                        <div class="col-xs-6">
                                                    <a href="#" id="login-form-link">Login</a>
                                                </div>-->
                        <div class="col-md-12">
                            <a href="#" class="active"  id="register-form-link">Register</a>
                        </div>
                    </div>
                    <hr>
                </div>

                <!--  Error -Success Messages -->
                <div class="row">
                    <div class="col-md-12">
                        <?php
                        $this->load->helper('form');
                       /* $error_msg = $this->session->flashdata('error');
                        if ($error_msg) {
                            ?>
                            <div class="alert alert-danger alert-dismissable">
                                <button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>
                                <?php echo $this->session->flashdata('error'); ?>                    
                            </div>
                        <?php } ?>
                        <?php
                        $success_msg = $this->session->flashdata('success');
                        if ($success_msg) {
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
                            <form id="register-form" action="<?php echo base_url(); ?>user/signup" method="post" role="form">
                            <div class="col-xs-12 col-sm-6 col-md-6">
                                <div class="form-group">
                                    <label for="firstname">First Name<span class="astrik">*</span></label>
                                    <input type="text" name="first_name" id="first_name" tabindex="1" class="form-control" placeholder="Enter first name" value="" required="">
                                    <span></span>
                                </div>
                           </div>
                           <div class="col-xs-12 col-sm-6 col-md-6">
                                <div class="form-group">
                                    <label for="lastname">Last Name<span class="astrik">*</span></label>
                                    <input type="text" name="last_name" id="last_name" tabindex="1" class="form-control" placeholder="Enter last name" value="" required=""> 
                                </div>
                            </div>
                            <div class="col-xs-12 col-sm-6 col-md-6">    
                                <div class="form-group">
                                    <label for="lastname">Mobile No.<span class="astrik">*</span></label>
                                    <input type="text" name="mobile" id="last_name" tabindex="1" class="form-control" placeholder="Enter mobile" value="" required=""> 
                                </div>
                            </div>
                            <div class="col-xs-12 col-sm-6 col-md-6">  
                                <div class="form-group">
                                    <label for="gender">Gender<span class="astrik">*</span></label>
                                    <select name="gender" id="gender"  tabindex="2" class="form-control" placeholder="Gender" required="">
                                        <option value="">Select Gender</option>
                                        <option value="Female">Female</option>
                                        <option value="Male">Male</option>

                                    </select>
                                </div>
                            </div>
                            <div class="col-xs-12 col-sm-6 col-md-6">  
                                <div class="form-group">
                                    <label for="lastname">Date Of Birth<span class="astrik">*</span></label>
                                    <input type="text" name="DOB" id="datepicker" tabindex="1" class="form-control date-picker" placeholder="mm/dd/yyyy" value="" required="">
                                </div>
                            </div>
                            <div class="col-xs-12 col-sm-6 col-md-6">  
                                <div class="form-group">
                                    <label for="lastname">Birth Time<span class="astrik">*</span></label>
                                    <input type="text" name="birth_time" id="timepicker1" tabindex="1" class="form-control timepicker1" placeholder="Select birth time" value="" required="">
                                </div>
                            </div>
                            <div class="col-xs-12 col-sm-12 col-md-12">  
                                <div class="form-group">
                                    <label for="username">Email Id<span class="astrik">*</span></label>
                                    <input type="text" name="email" id="email" tabindex="1" class="form-control" placeholder="Enter email" value="" required="">
                                    <span id="checkemail" style="color:red"></span>
                                </div>
                            </div>
                            <div class="col-xs-12 col-sm-6 col-md-6">  
                                <div class="form-group">
                                    <label for="password">Password<span class="astrik">*</span></label>
                                    <input type="password" name="password" id="password"  tabindex="2" class="form-control" placeholder="Enter password"  required=""> 
                                </div>
                            </div>
                            <div class="col-xs-12 col-sm-6 col-md-6">  
                                <div class="form-group">
                                    <label for="confirm-password">Confirm password<span class="astrik">*</span></label>
                                    <input type="password" name="confirm_password" id="confirm_password" tabindex="2" class="form-control" placeholder="Enter confirm password" required="">
                                </div>
                            </div>
                            <div class="col-xs-12 col-sm-6 col-md-6">  
                                <div class="form-group">
                                <input type="submit" name="register-submit" id="register-submit" tabindex="4" class="form-control btn btn-register" value="Register Now">
                                </div>
                            </div>
                               
                                <div class="form-group text-center">
                                    <a href="<?php echo base_url(); ?>user">Already on fensghui web app? Sign in </a>
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
</div>


