
<!------ Include the above in your HEAD tag ---------->
<div id="login">
    <div id="regContainer" class="container">
        <div class="row">
            <div class="col-md-6 col-sm-8 col-xs-10 col-sm-offset-2 col-md-offset-3 col-xs-offset-1">
                <div class="panel panel-login">
                    <div class="panel-heading">
                        <div class="row">
                            <div class="col-md-12">
                                <a href="#" class="active" id="login-form-link">Login</a>
                            </div>
                            <!--<div class="col-xs-6">
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
                                <form id="login-form" action="<?php echo base_url(); ?>user/signin" method="post" role="form" style="display: block;">
                                    <div class="form-group">
                                        <label for="username">Email Id<span class="astrik">*</span></span></label>
                                        <input type="email" name="username" id="username" tabindex="1" class="form-control" placeholder="Enter email " value="" required="">
                                    </div>
                                    <div class="form-group">
                                        <label for="password">Password<span class="astrik">*</span></label>
                                        <input type="password" name="password" id="password" tabindex="2" class="form-control" placeholder="Enter password" required="">
                                    </div>

                                    <div class="form-group">
                                        <div class="row">
                                            <div class="col-sm-6 col-sm-offset-3">
                                                <input type="submit" name="login-submit" id="login-submit" tabindex="4" class="form-control btn btn-login" value="Log In">
                                            </div>
                                        </div>
                                    </div>
                                    <div class="form-group text-center">
                                        <a href="#" data-toggle="modal" data-target="#forgotpassword">Forgot Password?</a><br/>
                                        <a href="<?php echo base_url(); ?>user/signup">New User? SignUp</a>
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
<!--Forgot password Modal -->
<div id="forgotpassword" class="modal fade" role="dialog">
    <div class="modal-dialog">
        <!-- Modal content-->
        <div class="modal-content">
            <div class="modal-header">

                <button type="button" class="close" data-dismiss="modal">&times;</button>
                <h4 class="modal-title">Forgot Password</h4>
            </div>
            <form method="POST" id="frm_fogpassword">  
                <div class="modal-body">
                    <span id="fg_success" style="color: green"></span>
                    <span id="fg_error" style="color: red"></span>
                    <input type="email" name="fogemail" class="form-control" id="fogemail" placeholder="Enter Your Register Email Id*" required="">
                    <span id="checkfogemail" style="color:red"></span>
                </div>
                <div class="modal-footer text-center">
                    <input type="button" name="btn_fogsubmit" id="btn_fogsubmit" tabindex="4" class="btn btn-default btn-gold" value="Submit">                                 
                </div>
            </form>      
        </div>

    </div>
</div>

<!-- This snippet uses Font Awesome 5 Free as a dependency. You can download it at fontawesome.io! -->

<section class="pricing py-5">
    <div class="container">
        <div class="row">
            <!-- Free Tier -->
           <div class="col-lg-4 mar-5">
                <div class="card mb-5 mb-lg-0">
                    <div class="card-body">
                        <h5 class="card-title text-muted text-uppercase text-center"> </h5>
                        <h6 class="card-price text-center">Free Plan <span class="period"></span></h6>
                        <hr>
                        <ul class="fa-ul insec">
                            <li><span class="fa-li"><i class="fa fa-check"></i></span>Natal Chart</li>
                            <li><span class="fa-li"><i class="fa fa-check"></i></span>Luck Pillar</li>
                            <li><span class="fa-li"><i class="fa fa-check"></i></span>Day Master</li>
                            <li><span class="fa-li"><i class="fa fa-check"></i></span>Favorable Directions</li>
                            <li><span class="fa-li"><i class="fa fa-check"></i></span>Unfavorable Directions</li>
                            <li><span class="fa-li"><i class="fa fa-check"></i></span>Growth stage</li>
                            <li><span class="fa-li"><i class="fa fa-check"></i></span>Life Star</li>
                            <li><span class="fa-li"><i class="fa fa-check"></i></span>Gua Chart</li>
                        </ul>
                        <a href="#login" class="btn btn-block btn-primary text-uppercase gold-btn">LogIn</a>
                    </div>
                </div>
            </div>
            <!-- Plus Tier -->
            <div class="col-lg-4 mar-5">
                <div class="card mb-5 mb-lg-0">
                    <div class="card-body">
                        <h5 class="card-title text-muted text-uppercase text-center"></h5>
                        <h6 class="card-price text-center">Paid Subscription <span class="period"></span></h6>
                        <hr>
                        <ul class="fa-ul insec">
                        <li><span class="fa-li"><i class="fa fa-check"></i></span>Know your Fengshui tip's for Property(Home,Office ect.)</li>
                            <li><span class="fa-li"><i class="fa fa-check"></i></span>Understand your Bazi(Astrology Chart),Character,Personality</li>
                            <li><span class="fa-li"><i class="fa fa-check"></i></span>Understand your Bazi print chart</li>
                            <!-- <li><span class="fa-li"><i class="fa fa-check"></i></span>Useful God</li>
                            <li><span class="fa-li"><i class="fa fa-check"></i></span>Remedies and suggestions </li>
                            <li><span class="fa-li"><i class="fa fa-check"></i></span>QI Men Destiny Palace</li>
                            <li><span class="fa-li"><i class="fa fa-check"></i></span>Reports In Detail</li> -->
                        </ul>
                        <a href="#" class="btn btn-block btn-primary text-uppercase gold-btn cus-none">Coming soon..</a>
                    </div>
                </div>
            </div>
            <!-- Pro Tier -->
            <div class="col-lg-4 mar-5">
                <div class="card">
                    <div class="card-body">
                        <h5 class="card-title text-muted text-uppercase text-center"></h5>
                        <h6 class="card-price text-center">One Time Payment  <span class="period"></span></h6>
                        <hr>
                       <ul class="fa-ul insec">
                            <li><span class="fa-li"><i class="fa fa-check"></i></span>Know your Fengshui tip's for Property(Home,Office ect.)</li>
                            <li><span class="fa-li"><i class="fa fa-check"></i></span>Understand your Bazi(Astrology Chart),Character,Personality</li>
                            <li><span class="fa-li"><i class="fa fa-check"></i></span>Understand your Bazi print chart</li>
                            <!--<li><span class="fa-li"><i class="fa fa-check"></i></span>QMDJ Fengshui (house Facing & door Facing)</li>
                            <li><span class="fa-li"><i class="fa fa-check"></i></span>QMDJ Fengshui (house Facing & door Facing)</li>
                            <li><span class="fa-li"><i class="fa fa-check"></i></span>Annual Fengshui (house Facing & door Facing)</li>
                            <li><span class="fa-li"><i class="fa fa-check"></i></span>House Nobleman (house Facing & door Facing)</li>
                            <li><span class="fa-li"><i class="fa fa-check"></i></span>Water Position (house Facing & door Facing)</li>
                            <li><span class="fa-li"><i class="fa fa-check"></i></span>Castle Goat (house Facing & door Facing)</li>
                            <li><span class="fa-li"><i class="fa fa-check"></i></span>Annual Water Position. (house Facing & door Facing)</li> -->
                        </ul>
                        <a href="#" class="btn btn-block btn-primary  text-uppercase gold-btn cus-none">Coming soon..</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>                            
