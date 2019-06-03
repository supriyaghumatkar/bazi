<?php 
$currentpage=$this->uri->uri_string();
$currentfunction=$this->router->fetch_method();
?>
<!DOCTYPE html>
<html lang="en">
	<head>
	
		<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
		<meta charset="utf-8" />
		<title>Fengshui</title>
        <link rel="shortcut icon" href="<?php echo get_assets_path(); ?>newcssjs/img/favicon.ico" type="image/x-icon">
        <link rel="icon" href="<?php echo get_assets_path(); ?>newcssjs/img/favicon.ico" type="image/x-icon">
		<meta name="description" content="overview &amp; stats" />
		<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0" />

		<!-- bootstrap & fontawesome -->
		<link rel="stylesheet" href="<?php echo get_assets_path(); ?>newcssjs/css/bootstrap.min.css" />
		<link rel="stylesheet" href="<?php echo get_assets_path(); ?>font-awesome/4.5.0/css/font-awesome.min.css" />
                <link rel="stylesheet" href="<?php echo get_assets_path(); ?>newcssjs/css/swipebox.css">
                <link rel="stylesheet" href="<?php echo get_assets_path(); ?>newcssjs/css/ace-skins.min.css" />
                <link rel="stylesheet" href="<?php echo get_assets_path(); ?>newcssjs/css/ace-rtl.min.css" />    

		
                <link rel="stylesheet" href="<?php echo get_assets_path(); ?>newcssjs/css/bootstrap-datetimepicker.min.css" />
		<link rel="stylesheet" href="<?php echo get_assets_path(); ?>newcssjs/css/daterangepicker.min.css" />
                <link rel="stylesheet" href="<?php echo get_assets_path(); ?>newcssjs/css/timepicki.css" />
		<link rel="stylesheet" href="<?php echo get_assets_path(); ?>newcssjs/css/bootstrap-datepicker3.min.css" />
                
                  <link href="<?php echo get_assets_path(); ?>newcssjs/css/default.css" type="text/css" rel="stylesheet" />  
                  <link href="<?php echo get_assets_path(); ?>newcssjs/css/default-nik.css" type="text/css" rel="stylesheet" />          
                <link href="<?php echo get_assets_path(); ?>newcssjs/css/login.css" type="text/css" rel="stylesheet" />
<!--                  <link rel="stylesheet" href="<?php echo get_assets_path(); ?>newcssjs/css/style2.css" type="text/css" media="all" />  Style-CSS  -->
                  
	</head>
 <body>

     <?php //if($currentfunction!='fensui_chart_personal_detail'){ ?>
    <div class="fullscreen_bgmain"></div>
     <?php //} ?>
        <div class="main-header clearfix" >	
            <nav class="navbar navbar-inverse pinkbg pos">
                <div class="container-fluid">
                    <div class="navbar-header">
                        
                       <?php if($currentpage!='user'){ ?>
                        <button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#myNavbar">
                            <span class="icon-bar"></span>
                            <span class="icon-bar"></span>
                            <span class="icon-bar"></span>                        
                        </button>
                       <?php } ?>
                        <a class="navbar-brand" href="http://sharmilamohanan.com/">
						<img class="logo" src="<?php echo get_assets_path();  ?>/images/logo_gold.png"/>
						<p class="headtext">
						SHARMILA MOHANAN BAZI APP</br>
						PERSONAL CHART FOR 2019</p><!--<img class="logo img-responsive" src="<?php echo get_assets_path(); ?>newcssjs/img/destiny-logo.png" alt="DESTINY 2019"/>--></a>
                        <!--<div class="hidden-xs header-title"></div>-->
                    </div>
                    
                  
                   <div class="collapse navbar-collapse" id="myNavbar">

                       <ul class="nav navbar-nav">
                       <li><a href="http://sharmilamohanan.com/" ><i class="home-ic"></i> Home</a></li>
		 <?php if($this->session->userdata('IsLogin')!=true){?>
                        <?php if(($currentfunction!='index' && $currentpage!='') || ($currentfunction!='index' && $currentpage!='user')){ ?>
                    <li><a href="<?php echo base_url() ?>user" ><i class="logout-ic"></i> Login</a></li>
                      <?php } ?>
                        <?php } else { ?>
                    
                     <li><a href="<?php echo base_url() ?>profile" ><i class="profile-ic"></i> Profile</a></li>
                     <?php if($currentfunction=='fensui_chart_personal_detail'){ ?>
				<li><a href="#" onclick="printDiv()"><i class="print-ic"></i> Print</a></li>
                         <?php } ?> 
                     <li><a href="<?php echo base_url() ?>user/logout"><i class="logout-ic"></i> Logout</a></li>
                <?php }?>
                     
				              
                               
                              </ul>
                        <!--<ul class="nav navbar-nav navbar-right">
                          <li><a href="#"><span class="glyphicon glyphicon-log-in"></span> Login</a></li>
                        </ul>-->
                    </div
                   
                </div>
            </nav>	  


        </div>
