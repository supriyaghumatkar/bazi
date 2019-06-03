<?php //extract($theme_confg); ?>
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <title>Fengshui</title>
  <!-- Tell the browser to be responsive to screen width -->
  <meta content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" name="viewport">
  <!-- Bootstrap 3.3.7 -->
  <link rel="stylesheet" href="<?php echo get_assets_path(); ?>theme/bower_components/bootstrap/dist/css/bootstrap.min.css">
  <!-- Font Awesome -->
  <link rel="stylesheet" href="<?php echo get_assets_path(); ?>theme/bower_components/font-awesome/css/font-awesome.min.css">
  <!-- Ionicons -->
  <link rel="stylesheet" href="<?php echo get_assets_path(); ?>theme/bower_components/Ionicons/css/ionicons.min.css">

    <link rel="stylesheet" href="<?php echo get_assets_path(); ?>theme/bower_components/bootstrap-daterangepicker/daterangepicker.css">
    <!-- DataTables -->
  <link rel="stylesheet" href="<?php echo get_assets_path(); ?>theme/bower_components/datatables.net-bs/css/dataTables.bootstrap.min.css">
  <link rel="stylesheet" href="<?php echo get_assets_path(); ?>theme/bower_components/datatables.net-bs/css/buttons.dataTables.min.css">
  <!-- bootstrap datepicker -->
  <link rel="stylesheet" href="<?php echo get_assets_path(); ?>theme/bower_components/bootstrap-datepicker/dist/css/bootstrap-datepicker.min.css">
  <!-- iCheck for checkboxes and radio inputs -->
  <link rel="stylesheet" href="<?php echo get_assets_path(); ?>theme/plugins/iCheck/all.css">
  <!-- Bootstrap Color Picker -->
  <link rel="stylesheet" href="<?php echo get_assets_path(); ?>theme/bower_components/bootstrap-colorpicker/dist/css/bootstrap-colorpicker.min.css">
  <!-- Bootstrap time Picker -->
  <link rel="stylesheet" href="<?php echo get_assets_path(); ?>theme/plugins/timepicker/bootstrap-timepicker.min.css">
  <!-- Select2 -->
  <link rel="stylesheet" href="<?php echo get_assets_path(); ?>theme/bower_components/select2/dist/css/select2.min.css">
    <!-- DataTables -->
  <link rel="stylesheet" href="<?php echo get_assets_path(); ?>theme/bower_components/datatables.net-bs/css/dataTables.bootstrap.min.css">
  <!-- Theme style -->
  <link rel="stylesheet" href="<?php echo get_assets_path(); ?>theme/dist/css/AdminLTE.min.css">
  <!-- AdminLTE Skins. Choose a skin from the css/skins
       folder instead of downloading all of them to reduce the load. -->
  <link rel="stylesheet" href="<?php echo get_assets_path(); ?>theme/dist/css/skins/_all-skins.min.css">
   <!-- <link rel="stylesheet" href="<?php echo get_assets_path(); ?>theme/dist/css/skins/skin-blue.css"> -->

  <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
  <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
  <!--[if lt IE 9]>
  <script src="https://oss.maxcdn.com/html5shiv/3.7.3/html5shiv.min.js"></script>
  <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
  <![endif]-->

  <!-- Google Font -->
  <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,600,700,300italic,400italic,600italic">
</head>
<body class="hold-transition skin-blue sidebar-mini">
<!-- Site wrapper -->
<div class="wrapper">

  <header class="main-header">
    <!-- Logo -->
    <a href="#" class="logo">
      <!-- mini logo for sidebar mini 50x50 pixels -->
      <span class="logo-mini"><img src="<?php echo get_assets_path(); ?>BackendImg/Icon01.png"></span>
      <!-- logo for regular state and mobile devices -->
      <span class="logo-lg"><img src="<?php echo get_assets_path(); ?>BackendImg/Icon02.png"></span>
    </a>
    <!-- Header Navbar: style can be found in header.less -->
    <nav class="navbar navbar-static-top">
      <!-- Sidebar toggle button-->
      <a href="#" class="sidebar-toggle" data-toggle="push-menu" role="button">
        <span class="sr-only">Toggle navigation</span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
      </a>

      
    </nav>
  </header>
  <!-- =============================================== -->
  <aside class="main-sidebar">    
    <section class="sidebar">
      <ul class="sidebar-menu" data-widget="tree">
      <li>
          <a href="<?php echo base_url(); ?>admin/dashboard">
            <i class="fa fa-building-o"></i> <span>Dashboard</span>
            <span class="pull-right-container">
            </span>
          </a>
        </li>    
        <li>
          <a href="<?php echo base_url(); ?>admin/register">
            <i class="fa fa-home"></i> <span>Register uesr</span>
            <span class="pull-right-container">
            </span>
          </a>
        </li>

         <!-- <li>
          <a href="<?php echo base_url(); ?>admin/candidates">
            <i class="fa fa-building-o"></i> <span>Candidates</span>
            <span class="pull-right-container">
            </span>
          </a>
        </li>

         <li>
          <a href="#">
            <i class="fa fa-question"></i> <span>Questions</span>
            <span class="pull-right-container">
            </span>
          </a>
        </li>

         <li>
          <a href="#">
            <i class="fa fa-question-circle"></i> <span>Quiz Sections</span>
            <span class="pull-right-container">
            </span>
          </a>
        </li>

         <li>
          <a href="#">
            <i class="fa fa-hourglass-2"></i> <span>Quiz</span>
            <span class="pull-right-container">
            </span>
          </a>
        </li>

        <li>
          <a href="#">
            <i class="fa fa-envelope"></i> <span>Quiz Result</span>
            <span class="pull-right-container">
            </span>
          </a>
        </li>

        <li>
          <a href="#">
            <i class="fa fa-exchange"></i> <span>Change Password</span>
            <span class="pull-right-container">
            </span>
          </a>
        </li> -->

        <li>
          <a href="<?php echo base_url(); ?>admin/login/logout">
            <i class="fa fa-power-off"></i> <span>Logout</span>
            <span class="pull-right-container">
            </span>
          </a>
        </li>
       
      </ul>
    </section>
    <!-- /.sidebar -->
  </aside>