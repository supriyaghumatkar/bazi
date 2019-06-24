<?php  extract($userdetail); ?>
<div class="profile-sec minheight">
<div class="container">

    <div class="row">
        <div class="col-md-12">
            <div class="vertical-tab" role="tabpanel">
                <!-- Nav tabs -->
                <ul class="nav nav-tabs" role="tablist">
                    <li role="presentation" class="active"><a href="#Section1" aria-controls="home" role="tab" data-toggle="tab">DASHBOARD</a></li>
                    <li role="presentation"><a href="#Section2" aria-controls="profile" role="tab" data-toggle="tab">PROFILE</a></li>
                    <li role="presentation"><a href="<?php echo base_url(); ?>user/logout">LOGOUT</a></li>
                </ul>
                <!-- Tab panes -->
                <div class="tab-content tabs">
                    <div role="tabpanel" class="tab-pane fade in active" id="Section1">
						<h3>Plot Chart</h3>
                                                <p>Dear <?php if(!empty($userdetail)){  echo $userdetail[0]['FirstName']." ".$userdetail[0]['LastName']; } ?>, welcome to your personal dashboard.Here you can view your Plot Bazi Chart and know many other things.Keep following this page for more Future updates.</p>
                        <p><a href="<?php echo base_url(); ?>chart" name="plotchart" id="ploatchart" class="btn btn-info" >Plot Bazi<br/> Chart</a></p>
						<p><a href="<?php echo base_url(); ?>Plan" name="plotchart" id="ploatchart" class="btn btn-info" >Fengshui</a></p>
						<!-- For Show Paid Version Packages -->

						<!-- <div class="row">
						<h2 id="details">Choose your package</h2>
					</div><br>
                    
                     
                       <!-Pack 1-->
                        <!-- <div class="col-md-3" id="home-box">
                            <div class="pricing_header">
                                <h2>Basic User</h2>
                                <div class="space"></div>
    						</div>
							<ul class="list-group">
                                    
									<li class="list-group-item"><input type="checkbox" value="10"/>Personal fengshui energy direction</li>
									<li class="list-group-item"><input type="checkbox" value="10"/> Flystar</li>
									<li class="list-group-item"><input type="checkbox" value="10"/>Qmdj fengshui direction</li>
									<li class="list-group-item"><input type="checkbox" value="10"/>24 Mountain</li>
									<li class="list-group-item"><input type="checkbox" value="10"/>House Gua</li>
									<li class="list-group-item off"><input type="checkbox" value="10"/> Personal noble man</li>
									<li class="list-group-item off"><input type="checkbox" value="10"/> Personal intelligence star</li>
									<li class="list-group-item off"><input type="checkbox" value="10"/> Personal noble man</li>
									<li class="list-group-item off"><input type="checkbox" value="10"/> Monthly star</li>
									<li class="list-group-item off"><input type="checkbox" value="10"/>House noble man</li>
									<li class="list-group-item off"><input type="checkbox" value="10"/>Dragon gate formation</li>
								</ul>
                                
                                <div class="try">
                                    <p class="price" id="total">$ 0</p>
                                    <a class="btn btn-default" href="#" type="button">Buy Now</a>
                                </div>
                            </div> -->
                        <!-- Pack 2-->
                        <!-- <div class="col-md-3" id="home-box">
                            <div class="pricing_header">
                                <h2>Basic User</h2>
                                <div class="space"></div>
    						</div>
							<ul class="list-group">
							        <li class="list-group-item"><span class="fas fa-check"></span>Personal fengshui energy direction</li>
									<li class="list-group-item"><span class="glyphicon glyphicon-ok"></span> Flystar</li>
									<li class="list-group-item"><span class="glyphicon glyphicon-ok"></span>Qmdj fengshui direction</li>
									<li class="list-group-item"><span class="glyphicon glyphicon-ok"></span> 24 Mountain</li>
									<li class="list-group-item"><span class="glyphicon glyphicon-ok"></span>House Gua</li>
									<li class="list-group-item off"><span class="glyphicon glyphicon-ok"></span> Personal noble man</li>
								</ul>
                                
                                <div class="try">
                                    <p class="price">$ 60</p>
                                    <a class="btn btn-default" href="#" type="button">Buy Now</a>
                                </div>
                            </div> -->

							<!-- Pack 3-->
							<!-- <div class="col-md-3" id="home-box">
                            <div class="pricing_header">
                                <h2>Basic User</h2>
                                <div class="space"></div>
    						</div>
							<ul class="list-group">
                                    
							        <li class="list-group-item off"><span class="glyphicon glyphicon-ok"></span> Personal intelligence star</li>
									<li class="list-group-item off"><span class="glyphicon glyphicon-ok"></span> Personal noble man</li>
									<li class="list-group-item off"><span class="glyphicon glyphicon-ok"></span> Monthly star</li>
									<li class="list-group-item off"><span class="glyphicon glyphicon-ok"></span> House noble man</li>
									<li class="list-group-item off"><span class="glyphicon glyphicon-ok"></span> Dragon gate formation</li>
								</ul>
                                 
                                <div class="try">
                                    <p class="price">$ 60</p>
                                    <a class="btn btn-default" href="#" type="button">Buy Now</a>
                                </div>
                            </div> -->
                        
                        <!-- Pack 4-->
                        <!-- <div class="col-md-3" id="home-box">
                            <div class="pricing_header">
                                <h2>Basic User</h2>
                                <div class="space"></div>
    						</div>
							<ul class="list-group">
                                    
							        <li class="list-group-item"><span class="glyphicon glyphicon-ok"></span>Personal fengshui energy direction</li>
									<li class="list-group-item"><span class="glyphicon glyphicon-ok"></span> Flystar</li>
									<li class="list-group-item"><span class="glyphicon glyphicon-ok"></span>Qmdj fengshui direction</li>
									<li class="list-group-item"><span class="glyphicon glyphicon-ok"></span> 24 Mountain</li>
									<li class="list-group-item"><span class="glyphicon glyphicon-ok"></span>House Gua</li>
									<li class="list-group-item off"><span class="glyphicon glyphicon-ok"></span> Personal noble man</li>
									<li class="list-group-item off"><span class="glyphicon glyphicon-ok"></span> Personal intelligence star</li>
									<li class="list-group-item off"><span class="glyphicon glyphicon-ok"></span> Personal noble man</li>
									<li class="list-group-item off"><span class="glyphicon glyphicon-ok"></span> Monthly star</li>
									<li class="list-group-item off"><span class="glyphicon glyphicon-ok"></span> House noble man</li>
									<li class="list-group-item off"><span class="glyphicon glyphicon-ok"></span> Dragon gate formation</li>
								</ul>
                                
                                <div class="try">
                                    <p class="price">$ 100</p>
                                    <a class="btn btn-default" href="#" type="button">Buy Now</a>
                                </div>
                            </div>
    -->
                    </div> 
                    <div role="tabpanel" class="tab-pane fade" id="Section2">
                        <h3>Edit Profile</h3>
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
						<form id="edit_profile" role="form" method="post" action="<?php echo base_url(); ?>profile/edit_profile">
							<hr class="colorgraph">
							<div class="row">
							<div class="col-xs-12 col-sm-6 col-md-6">
							<div class="form-group">
							<input type="text" name="first_name"  id="first_name" tabindex="1" class="form-control" <?php if(!empty($userdetail)){ ?> value="<?php echo $userdetail[0]['FirstName'];  ?>" <?php } ?> placeholder="First Name" value="" required="">
							</div>
							</div>
							<div class="col-xs-12 col-sm-6 col-md-6">
							<div class="form-group">
							<input type="text" name="last_name" id="last_name" tabindex="1" <?php if(!empty($userdetail)){ ?> value="<?php echo $userdetail[0]['LastName'];  ?>" <?php } ?> class="form-control" placeholder="Last Name" value="" required=""> 
							</div>
							</div>
							</div>
							<div class="form-group">
							<input type="text" name="mobile" <?php if(!empty($userdetail)){ ?> value="<?php echo $userdetail[0]['Mobile'];  ?>" <?php } ?> id="mobile" tabindex="1" class="form-control" placeholder="mobile" value="" required=""> 
							</div>
							<div class="row">
							<div class="col-xs-12 col-sm-6 col-md-6">
							<div class="form-group">
							<select name="gender" id="gender" tabindex="2" class="form-control" placeholder="Gender" required="">
							<option value="">Select Gender</option>
							<?php if(!empty($userdetail)) { ?> 
							<option value="Female" <?php if($userdetail[0]['Gender']=='Female') {  ?> selected="selected" <?php } ?>>Female</option>
							<option value="Male"  <?php if($userdetail[0]['Gender']=='Male') { ?> selected="selected" <?php } ?>>Male</option>
							<?php } else { ?>
								<option value="Female">Female</option>
							<option value="Male">Male</option>
								<?php } ?>
							</select>
							</div>
							</div>
							<div class="col-xs-12 col-sm-6 col-md-6">
							<div class="form-group">
							<input type="text" name="DOB" id="datepicker" tabindex="1"  <?php if(!empty($userdetail)) { ?> value="<?php echo $userdetail[0]['BirthDate'];  ?>" <?php } ?> class="form-control date-picker" placeholder="Select Date" value="" required="">
							</div>
							</div>
							</div>
							<div class="row">
							<div class="col-xs-12 col-sm-6 col-md-6">
							<div class="form-group">
							<input type="text" name="birth_time" id="timepicker1"   <?php if(!empty($userdetail)) { ?> value="<?php echo $userdetail[0]['BirthTime'];  ?>" <?php } ?>  tabindex="1" class="form-control timepicker1" placeholder="Select Time" value="" required="">
							</div>
							</div>
							<div class="col-xs-12 col-sm-6 col-md-6">
							<div class="form-group">
							<input type="text" readonly name="email" id="email" tabindex="1"   <?php if(!empty($userdetail)) { ?> value="<?php echo $userdetail[0]['Email'];  ?>" <?php } ?> class="form-control" placeholder="Email ID" value="" required="">
							</div>
							</div>
							</div>
							<hr class="colorgraph">
							<div class="row">
							<div class="col-xs-12 col-md-6"><button type="submit" class="btn btn-success btn-block btn-lg gold-btn">Save</button></div>
							</div>
							</form>
						
                    </div>
                    <div role="tabpanel" class="tab-pane fade" id="Section3">
                        <h3>Section 3</h3>
                        <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce semper, magna a ultricies volutpat, mi eros viverra massa, vitae consequat nisi justo in tortor. Proin accumsan felis ac felis dapibus, non iaculis mi varius.</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
</div>
