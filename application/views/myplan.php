
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
                            <a href="#" class="active"  id="register-form-link">My Plans</a>
                          
                        </div>
                      
                    </div>
                    <hr>
                </div>
               
		<!--  Error -Success Messages -->
					<div class="row">
						<div class="col-md-12">
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
                           
<div class="row">
				
					</div><br>
                    
                     
                       <!--Pack 1-->
                       <div class="col-md-12" id="home-box">
                            <div class="pricing_header">
                            
                                <div class="space"></div>
    						</div>
							<ul class="list-group">
                                    
									<li class="list-group-item"><a href="<?php echo base_url(); ?>plan?report_id=<?php echo md5(1);?>">Personal fengshui energy direction</a></li>
									<li class="list-group-item"><a href="<?php echo base_url(); ?>plan?report_id=<?php echo md5(2);?>"> Flystar</a></li>
									<li class="list-group-item"><a href="#<?php echo base_url(); ?>plan?report_id=<?php echo md5(3);?>">Qmdj fengshui direction</a></li>
									<li class="list-group-item"><a href="#<?php echo base_url(); ?>plan?report_id=<?php echo md5(4);?>">24 Mountain</a></li>
									<li class="list-group-item"><a href="<?php echo base_url(); ?>plan?report_id=<?php echo md5(5);?>">House Gua</a></li>
									<li class="list-group-item off"><a href="<?php echo base_url(); ?>plan?report_id=<?php echo md5(6);?>"> Personal noble man</a></li>
									<li class="list-group-item off"><a href="<?php echo base_url(); ?>plan?report_id=<?php echo md5(7);?>"> Personal intelligence star</a></li>
									<li class="list-group-item off"><a href="<?php echo base_url(); ?>plan?report_id=<?php echo md5(8);?>">Personal noble man</a></li>
									<li class="list-group-item off"><a href="<?php echo base_url(); ?>plan?report_id=<?php echo md5(9);?>"> Monthly star</a></li>
									<li class="list-group-item off"><a href="<?php echo base_url(); ?>plan?report_id=<?php echo md5(10);?>">House noble man</a></li>
									<li class="list-group-item off"><a href="<?php echo base_url(); ?>plan?report_id=<?php echo md5(11);?>">Dragon gate formation</a></li>
								</ul>
                                
                                
                            </div> 
                            </div>
       
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
  </div>
</div>                       