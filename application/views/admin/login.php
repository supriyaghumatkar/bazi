<?php 
if(isset($logodetails) && is_array($logodetails) && !empty($logodetails))
{
   extract($logodetails);
} ?>
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <title>AdminLTE 2 | Log in</title>
  <!-- Tell the browser to be responsive to screen width -->
  <meta content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" name="viewport">
  <!-- Bootstrap 3.3.7 -->
  <link rel="stylesheet" href="<?php echo get_assets_path(); ?>theme/bower_components/bootstrap/dist/css/bootstrap.min.css">
  <!-- Font Awesome -->
  <link rel="stylesheet" href="<?php echo get_assets_path(); ?>theme/bower_components/font-awesome/css/font-awesome.min.css">
  <!-- Ionicons -->
  <link rel="stylesheet" href="<?php echo get_assets_path(); ?>theme/bower_components/Ionicons/css/ionicons.min.css">
  <!-- Theme style -->
  <link rel="stylesheet" href="<?php echo get_assets_path(); ?>theme/dist/css/AdminLTE.min.css">
  <link rel="stylesheet" href="<?php echo get_assets_path(); ?>theme/dist/css/custom.css">
  <!-- iCheck -->
  <link rel="stylesheet" href="<?php echo get_assets_path(); ?>theme/plugins/iCheck/square/blue.css">

  <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
  <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
  <!--[if lt IE 9]>
  <script src="https://oss.maxcdn.com/html5shiv/3.7.3/html5shiv.min.js"></script>
  <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
  <![endif]-->

  <!-- Google Font -->
  <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,600,700,300italic,400italic,600italic">
</head>
<body class="hold-transition login-page">
<div class="login-box">
  <center><div class="login-logo">
    <a href="#"><img src="<?php echo get_assets_path(); ?>images/logo_gold.png" style="width: 100%;"/></a>
  </div></center>
  <!-- /.login-logo -->
  <div class="login-box-body">
    <p class="login-box-msg">Sign in to start your session</p>

    <form action="<?php echo base_url(); ?>admin/login/loginMe" method="post" id="frm_login">
    <div class="row">
          <div class="col-md-12">
            <?php
                    $this->load->helper('form');
                    $error = $this->session->flashdata('error');
                    if($error)
                    {
                  ?>
              <div class="alert alert-danger alert-dismissable">
                <button type="button" class="close" data-dismiss="alert" aria-hidden="true">×</button>
                <?php echo $this->session->flashdata('error'); ?>
              </div>
              <?php } ?>
              <?php  
                    $success = $this->session->flashdata('success');
                    if($success)
                    {
                  ?>
              <div class="alert alert-success alert-dismissable">
                <button type="button" class="close" data-dismiss="alert" aria-hidden="true">×</button>
                <?php echo $this->session->flashdata('success'); ?>
              </div>
              <?php } ?>

              <div class="row">
                <div class="col-md-12">
                  <?php echo validation_errors('<div class="alert alert-danger alert-dismissable">',' <button type="button" class="close" data-dismiss="alert" aria-hidden="true">×</button></div>'); ?>
                </div>
              </div>
          </div>
          <!--  /Error -Success Messages -->
      </div>
      
      <div class="form-group has-feedback">
        <input type="text" class="form-control" placeholder="Email ID" name="user_name" id="user_name" required="">
        <span class="glyphicon glyphicon-envelope form-control-feedback"></span>
      </div>
      <div class="form-group has-feedback">
        <input type="password" class="form-control" placeholder="Password" name="user_pass" id="user_pass" required="">
        <span class="glyphicon glyphicon-lock form-control-feedback"></span>
      </div>
      <div class="row">
        <div class="col-xs-12" style="text-align: center;">
          <div class="checkbox icheck">
            <label>
             <button type="submit" class="btn btn-primary btn-block btn-flat">Sign In</button>
            </label>
          </div>
        </div>
        <!-- /.col -->
      
        <!-- /.col -->
      </div>
    
     
    </form>
 <!--  <div class="social-auth-links text-center">
      <p>- OR -</p>
      <a href="#" class="btn btn-block btn-social btn-facebook btn-flat"><i class="fa fa-facebook"></i> Sign in using
        Facebook</a>
      <a href="#" class="btn btn-block btn-social btn-google btn-flat"><i class="fa fa-google-plus"></i> Sign in using
        Google+</a>
    </div> -->
    <!-- /.social-auth-links -->

   <!--  <a href="#">I forgot my password</a><br>
    <a href="register.html" class="text-center">Register a new membership</a> -->

  </div>
  <!-- /.login-box-body -->
</div>
<!-- /.login-box -->

<!-- jQuery 3 -->
<script src="<?php echo get_assets_path(); ?>theme/bower_components/jquery/dist/jquery.min.js"></script>
<!-- Bootstrap 3.3.7 -->
<script src="<?php echo get_assets_path(); ?>theme/bower_components/bootstrap/dist/js/bootstrap.min.js"></script>
<!-- iCheck -->
<script src="<?php echo get_assets_path(); ?>theme/plugins/iCheck/icheck.min.js"></script>
<script src="<?php echo get_assets_path(); ?>theme/plugins/jquery-validation/js/jquery.validate.min.js" type="text/javascript"></script>
        <script src="<?php echo get_assets_path(); ?>theme/plugins/jquery-validation/js/additional-methods.min.js" type="text/javascript"></script>

<script>
  $(function () {
    $('input').iCheck({
      checkboxClass: 'icheckbox_square-blue',
      radioClass: 'iradio_square-blue',
      increaseArea: '20%' /* optional */
    });

    $("#frm_login").validate({
            errorClass: "help-inline text-danger",
            errorElement: "span",
            rules: {
                user_name: {
                    required: true,
                    email: true
                },
                user_pass: {
                    required: true,
                },
    
            },
            messages: {
                user_name: {"required": "Enter email", "email": "Enter valid email"},
                user_pass: {"required": "Enter password"},
            }
        });    
  });
</script>
</body>
</html>
