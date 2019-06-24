<?php
extract($data);
?>
<div id="printableArea">
		
        <div class="navbar-header  pinkbg printheader">
                     
                      <a class="navbar-brand" href="#">
                      <img class="logo" src="http://demo33.blink-interact.com/fengshui/assets/images/logo_gold.png">
                      <p class="headtext white">
                      SHARMILA MOHANAN FENG SHUI APP<br>
                      PERSONAL CHART FOR 2019</p><!--<img class="logo img-responsive" src="http://demo33.blink-interact.com/fengshui/assets/newcssjs/img/destiny-logo.png" alt="DESTINY 2019"/>--></a>
                    
                  </div>
      <div class="container-fluid">
          <div class="row sub-header greybg grey">
              <div class="col-sm-10 pull-left ">
                  <ul>
                      <li class="fullrow">
                          <h1><?php echo $name; ?></h1>
                      </li>			
                      <li class="subheader-llink greysep">
                          <?php echo date('d M Y', strtotime($DOB)) . "  " . date('h:i a', strtotime($birthtime)); ?>
                      </li>
                      <li class="subheader-llink greysep">
                          <?php echo $gender; ?>
                      </li>
                      <!--<li class="subheader-llink ">
                          <a class="white" href="#">Add website address</a>
                      </li>-->
                  </ul>
              </div>


             <!-- <div class="col-md-2 pull-right subheader-rlink hidden-xs hidden-sm">
                  <?php if($this->session->userdata('IsLogin')!=true){?>
                  <a class="pink" href="<?php echo base_url() ?>user" style="float: right">Login</a>
                      <?php } else { ?>
                   <a  class="white" href="<?php echo base_url() ?>user/logout" style="float: right">Logout</a>
              <?php }?>
                   <a  class="white" href="#" onclick="printDiv()">Print</a>



              </div>-->

          </div>
        <div class="row">
         
        <div>
            <div style='width:30%; margin:0 auto'>
            <h2>PERSONAl DIRECTION REPORT</h2>
            <?php $this->load->view('svg.php');?>
            <span><button class="btn btn-sm"  style="background-color:#c6c6c6;"></button> </span>: Favrable Direction
            <span ><button class="btn btn-sm" style="background-color:#9b9090;"></button> </span>: UnFavrable Direction
               <?php extract($favorable_directionval); ?>
                    <table width="100%" class="favorable-directions">
                        <tr><th colspan="2">FAVORABLE DIRECTIONS</th></tr>
                        <tr><td width="60%">Sheng Chi <span class="minitext">(Career And Wealth)</span></td><td  width="40%">: <?php echo $favorable_directionval[0]['sheng_chi']; ?></td></tr>
                        <tr><td>Tien Yee <span class="minitext">(Health)</span></td><td>: <?php echo $favorable_directionval[0]['tien_yee']; ?></td></tr>
                        <tr><td>Yin Nian <span class="minitext">(Relationship)</span></td><td>: <?php echo $favorable_directionval[0]['yin_nien']; ?></td></tr>
                        <tr><td>Fu Wei <span class="minitext">(Personal Growth)</span></td><td>: <?php echo $favorable_directionval[0]['fu_wei']; ?></td></tr>
                    </table>			
                    <table width="100%" class="unfavorable-directions">
                        <tr><th  colspan="2">UNFAVORABLE DIRECTIONS</th></tr>
                        <tr><td  width="60%">Jue Ming <span class="minitext">(Total Loss)</span></td><td  width="40%">: <?php echo $unfavorable_directionval[0]['chueh_ming']; ?></td></tr>
                        <tr><td>Liu Sha <span class="minitext">(Six Killing)</span></td><td>: <?php echo $unfavorable_directionval[0]['liu_sha']; ?></td></tr>
                        <tr><td>Wu Kwei <span class="minitext">(Five Ghost)</span></td><td>: <?php echo $unfavorable_directionval[0]['wu_kwei']; ?></td></tr>
                        <tr><td>Who Hai <span class="minitext">(Unlucky)</span></td><td>: <?php echo $unfavorable_directionval[0]['who_hai']; ?></td></tr>
                    </table>             

        </div>
        </div>
</div>

 <script>
$(document).ready(function(){
//favorable Direction
    var sheng_chi="<?php echo $favorable_directionval[0]['sheng_chi'];?>";
    var tien_yee="<?php echo $favorable_directionval[0]['tien_yee'];?>";
    var yin_nien="<?php echo $favorable_directionval[0]['yin_nien'];?>";
    var fu_wei="<?php echo $favorable_directionval[0]['fu_wei'];?>";

//Unfavorable Direction
    var chueh_ming="<?php echo $unfavorable_directionval[0]['chueh_ming'];?>";
    var liu_sha="<?php echo $unfavorable_directionval[0]['liu_sha'];?>";
    var wu_kwei="<?php echo $unfavorable_directionval[0]['wu_kwei'];?>";
    var who_hai="<?php echo $unfavorable_directionval[0]['who_hai'];?>";

//for sheng chi
    if(sheng_chi=="E")
    {
        $("#e").css("fill", "#c6c6c6");
        $("#e1").css("fill", "#c6c6c6");
        $("#e2").css("fill", "#c6c6c6");
        $("#e3").css("fill", "#c6c6c6");
    }
    
    if(sheng_chi=="W") 
    {
        $("#w").css("fill", "#c6c6c6");
        $("#w1").css("fill", "#c6c6c6");
        $("#w2").css("fill", "#c6c6c6");
        $("#w3").css("fill", "#c6c6c6");
    }
    if(sheng_chi=="N")
    {
        $("#n").css("fill", "#c6c6c6");
        $("#n1").css("fill", "#c6c6c6");
        $("#n2").css("fill", "#c6c6c6");
        $("#n3").css("fill", "#c6c6c6");
    }
   
    if(sheng_chi=="S")
    {
        $("#s").css("fill", "#c6c6c6");
        $("#s1").css("fill", "#c6c6c6");
        $("#s2").css("fill", "#c6c6c6");
        $("#s3").css("fill", "#c6c6c6");
    }
    if(sheng_chi=="NE")
    {
        $("#ne").css("fill", "#c6c6c6");
        $("#ne1").css("fill", "#c6c6c6");
        $("#ne2").css("fill", "#c6c6c6");
        $("#ne3").css("fill", "#c6c6c6");
    }
    if(sheng_chi=="SE")
    {
        $("#se").css("fill", "#c6c6c6");
        $("#se1").css("fill", "#c6c6c6");
        $("#se2").css("fill", "#c6c6c6");
        $("#se3").css("fill", "#c6c6c6");
    }
    if(sheng_chi=="NW")
    {
        $("#nw").css("fill", "#c6c6c6");
        $("#nw1").css("fill", "#c6c6c6");
        $("#nw2").css("fill", "#c6c6c6");
        $("#nw3").css("fill", "#c6c6c6");
    }
    if(sheng_chi=="SW")
    {
        $("#sw").css("fill", "#c6c6c6");
        $("#sw1").css("fill", "#c6c6c6");
        $("#sw2").css("fill", "#c6c6c6");
        $("#sw3").css("fill", "#c6c6c6");
        
    }
  //for tien_yee
  if(tien_yee=="E")
    {
        $("#e").css("fill", "#c6c6c6");
        $("#e1").css("fill", "#c6c6c6");
        $("#e2").css("fill", "#c6c6c6");
        $("#e3").css("fill", "#c6c6c6");
    }
    
    if(tien_yee=="W") 
    {
        $("#w").css("fill", "#c6c6c6");
        $("#w1").css("fill", "#c6c6c6");
        $("#w2").css("fill", "#c6c6c6");
        $("#w3").css("fill", "#c6c6c6");
    }
    if(tien_yee=="N")
    {
        $("#n").css("fill", "#c6c6c6");
        $("#n1").css("fill", "#c6c6c6");
        $("#n2").css("fill", "#c6c6c6");
        $("#n3").css("fill", "#c6c6c6");
    }
   
    if(tien_yee=="S")
    {
        $("#s").css("fill", "#c6c6c6");
        $("#s1").css("fill", "#c6c6c6");
        $("#s2").css("fill", "#c6c6c6");
        $("#s3").css("fill", "#c6c6c6");
    }
    if(tien_yee=="NE")
    {
        $("#ne").css("fill", "#c6c6c6");
        $("#ne1").css("fill", "#c6c6c6");
        $("#ne2").css("fill", "#c6c6c6");
        $("#ne3").css("fill", "#c6c6c6");
    }
    if(tien_yee=="SE")
    {
        $("#se").css("fill", "#c6c6c6");
        $("#se1").css("fill", "#c6c6c6");
        $("#se2").css("fill", "#c6c6c6");
        $("#se3").css("fill", "#c6c6c6");
    }
    if(tien_yee=="NW")
    {
        $("#nw").css("fill", "#c6c6c6");
        $("#nw1").css("fill", "#c6c6c6");
        $("#nw2").css("fill", "#c6c6c6");
        $("#nw3").css("fill", "#c6c6c6");
    }
    if(tien_yee=="SW")
    {
        $("#sw").css("fill", "#c6c6c6");
        $("#sw1").css("fill", "#c6c6c6");
        $("#sw2").css("fill", "#c6c6c6");
        $("#sw3").css("fill", "#c6c6c6");
        
    }

    //for yin_nien
  if(yin_nien=="E")
    {
        $("#e").css("fill", "#c6c6c6");
        $("#e1").css("fill", "#c6c6c6");
        $("#e2").css("fill", "#c6c6c6");
        $("#e3").css("fill", "#c6c6c6");
    }
    
    if(yin_nien=="W") 
    {
        $("#w").css("fill", "#c6c6c6");
        $("#w1").css("fill", "#c6c6c6");
        $("#w2").css("fill", "#c6c6c6");
        $("#w3").css("fill", "#c6c6c6");
    }
    if(yin_nien=="N")
    {
        $("#n").css("fill", "#c6c6c6");
        $("#n1").css("fill", "#c6c6c6");
        $("#n2").css("fill", "#c6c6c6");
        $("#n3").css("fill", "#c6c6c6");
    }
   
    if(yin_nien=="S")
    {
        $("#s").css("fill", "#c6c6c6");
        $("#s1").css("fill", "#c6c6c6");
        $("#s2").css("fill", "#c6c6c6");
        $("#s3").css("fill", "#c6c6c6");
    }
    if(yin_nien=="NE")
    {
        $("#ne").css("fill", "#c6c6c6");
        $("#ne1").css("fill", "#c6c6c6");
        $("#ne2").css("fill", "#c6c6c6");
        $("#ne3").css("fill", "#c6c6c6");
    }
    if(yin_nien=="SE")
    {
        $("#se").css("fill", "#c6c6c6");
        $("#se1").css("fill", "#c6c6c6");
        $("#se2").css("fill", "#c6c6c6");
        $("#se3").css("fill", "#c6c6c6");
    }
    if(yin_nien=="NW")
    {
        $("#nw").css("fill", "#c6c6c6");
        $("#nw1").css("fill", "#c6c6c6");
        $("#nw2").css("fill", "#c6c6c6");
        $("#nw3").css("fill", "#c6c6c6");
    }
    if(yin_nien=="SW")
    {
        $("#sw").css("fill", "#c6c6c6");
        $("#sw1").css("fill", "#c6c6c6");
        $("#sw2").css("fill", "#c6c6c6");
        $("#sw3").css("fill", "#c6c6c6");
        
    }

  //for fu_wei
  if(fu_wei=="E")
    {
        $("#e").css("fill", "#c6c6c6");
        $("#e1").css("fill", "#c6c6c6");
        $("#e2").css("fill", "#c6c6c6");
        $("#e3").css("fill", "#c6c6c6");
    }
    
    if(fu_wei=="W") 
    {
        $("#w").css("fill", "#c6c6c6");
        $("#w1").css("fill", "#c6c6c6");
        $("#w2").css("fill", "#c6c6c6");
        $("#w3").css("fill", "#c6c6c6");
    }
    if(fu_wei=="N")
    {
        $("#n").css("fill", "#c6c6c6");
        $("#n1").css("fill", "#c6c6c6");
        $("#n2").css("fill", "#c6c6c6");
        $("#n3").css("fill", "#c6c6c6");
    }
   
    if(fu_wei=="S")
    {
        $("#s").css("fill", "#c6c6c6");
        $("#s1").css("fill", "#c6c6c6");
        $("#s2").css("fill", "#c6c6c6");
        $("#s3").css("fill", "#c6c6c6");
    }
    if(fu_wei=="NE")
    {
        $("#ne").css("fill", "#c6c6c6");
        $("#ne1").css("fill", "#c6c6c6");
        $("#ne2").css("fill", "#c6c6c6");
        $("#ne3").css("fill", "#c6c6c6");
    }
    if(fu_wei=="SE")
    {
        $("#se").css("fill", "#c6c6c6");
        $("#se1").css("fill", "#c6c6c6");
        $("#se2").css("fill", "#c6c6c6");
        $("#se3").css("fill", "#c6c6c6");
    }
    if(fu_wei=="NW")
    {
        $("#nw").css("fill", "#c6c6c6");
        $("#nw1").css("fill", "#c6c6c6");
        $("#nw2").css("fill", "#c6c6c6");
        $("#nw3").css("fill", "#c6c6c6");
    }
    if(fu_wei=="SW")
    {
        $("#sw").css("fill", "#c6c6c6");
        $("#sw1").css("fill", "#c6c6c6");
        $("#sw2").css("fill", "#c6c6c6");
        $("#sw3").css("fill", "#c6c6c6");
        
    }
//End favorable Direction
//start unfavorable Direction

//for chueh_ming
if(chueh_ming=="E")
    {
        $("#e").css("fill", "#9b9090");
        $("#e1").css("fill", "#9b9090");
        $("#e2").css("fill", "#9b9090");
        $("#e3").css("fill", "#9b9090");
    }
    
    if(chueh_ming=="W") 
    {
        $("#w").css("fill", "#9b9090");
        $("#w1").css("fill", "#9b9090");
        $("#w2").css("fill", "#9b9090");
        $("#w3").css("fill", "#9b9090");
    }
    if(chueh_ming=="N")
    {
        $("#n").css("fill", "#9b9090");
        $("#n1").css("fill", "#9b9090");
        $("#n2").css("fill", "#9b9090");
        $("#n3").css("fill", "#9b9090");
    }
   
    if(chueh_ming=="S")
    {
        $("#s").css("fill", "#9b9090");
        $("#s1").css("fill", "#9b9090");
        $("#s2").css("fill", "#9b9090");
        $("#s3").css("fill", "#9b9090");
    }
    if(chueh_ming=="NE")
    {
        $("#ne").css("fill", "#9b9090");
        $("#ne1").css("fill", "#9b9090");
        $("#ne2").css("fill", "#9b9090");
        $("#ne3").css("fill", "#9b9090");
    }
    if(chueh_ming=="SE")
    {
        $("#se").css("fill", "#9b9090");
        $("#se1").css("fill", "#9b9090");
        $("#se2").css("fill", "#9b9090");
        $("#se3").css("fill", "#9b9090");
    }
    if(chueh_ming=="NW")
    {
        $("#nw").css("fill", "#9b9090");
        $("#nw1").css("fill", "#9b9090");
        $("#nw2").css("fill", "#9b9090");
        $("#nw3").css("fill", "#9b9090");
    }
    if(chueh_ming=="SW")
    {
        $("#sw").css("fill", "#9b9090");
        $("#sw1").css("fill", "#9b9090");
        $("#sw2").css("fill", "#9b9090");
        $("#sw3").css("fill", "#9b9090");
        
    }
  //for liu_sha
  if(liu_sha=="E")
    {
        $("#e").css("fill", "#9b9090");
        $("#e1").css("fill", "#9b9090");
        $("#e2").css("fill", "#9b9090");
        $("#e3").css("fill", "#9b9090");
    }
    
    if(liu_sha=="W") 
    {
        $("#w").css("fill", "#9b9090");
        $("#w1").css("fill", "#9b9090");
        $("#w2").css("fill", "#9b9090");
        $("#w3").css("fill", "#9b9090");
    }
    if(liu_sha=="N")
    {
        $("#n").css("fill", "#9b9090");
        $("#n1").css("fill", "#9b9090");
        $("#n2").css("fill", "#9b9090");
        $("#n3").css("fill", "#9b9090");
    }
   
    if(liu_sha=="S")
    {
        $("#s").css("fill", "#9b9090");
        $("#s1").css("fill", "#9b9090");
        $("#s2").css("fill", "#9b9090");
        $("#s3").css("fill", "#9b9090");
    }
    if(liu_sha=="NE")
    {
        $("#ne").css("fill", "#9b9090");
        $("#ne1").css("fill", "#9b9090");
        $("#ne2").css("fill", "#9b9090");
        $("#ne3").css("fill", "#9b9090");
    }
    if(liu_sha=="SE")
    {
        $("#se").css("fill", "#9b9090");
        $("#se1").css("fill", "#9b9090");
        $("#se2").css("fill", "#9b9090");
        $("#se3").css("fill", "#9b9090");
    }
    if(liu_sha=="NW")
    {
        $("#nw").css("fill", "#9b9090");
        $("#nw1").css("fill", "#9b9090");
        $("#nw2").css("fill", "#9b9090");
        $("#nw3").css("fill", "#9b9090");
    }
    if(liu_sha=="SW")
    {
        $("#sw").css("fill", "#9b9090");
        $("#sw1").css("fill", "#9b9090");
        $("#sw2").css("fill", "#9b9090");
        $("#sw3").css("fill", "#9b9090");
        
    }

   //for wu_kwei
   if(wu_kwei=="E")
    {
        $("#e").css("fill", "#9b9090");
        $("#e1").css("fill", "#9b9090");
        $("#e2").css("fill", "#9b9090");
        $("#e3").css("fill", "#9b9090");
    }
    
    if(wu_kwei=="W") 
    {
        $("#w").css("fill", "#9b9090");
        $("#w1").css("fill", "#9b9090");
        $("#w2").css("fill", "#9b9090");
        $("#w3").css("fill", "#9b9090");
    }
    if(wu_kwei=="N")
    {
        $("#n").css("fill", "#9b9090");
        $("#n1").css("fill", "#9b9090");
        $("#n2").css("fill", "#9b9090");
        $("#n3").css("fill", "#9b9090");
    }
   
    if(wu_kwei=="S")
    {
        $("#s").css("fill", "#9b9090");
        $("#s1").css("fill", "#9b9090");
        $("#s2").css("fill", "#9b9090");
        $("#s3").css("fill", "#9b9090");
    }
    if(wu_kwei=="NE")
    {
        $("#ne").css("fill", "#9b9090");
        $("#ne1").css("fill", "#9b9090");
        $("#ne2").css("fill", "#9b9090");
        $("#ne3").css("fill", "#9b9090");
    }
    if(wu_kwei=="SE")
    {
        $("#se").css("fill", "#9b9090");
        $("#se1").css("fill", "#9b9090");
        $("#se2").css("fill", "#9b9090");
        $("#se3").css("fill", "#9b9090");
    }
    if(wu_kwei=="NW")
    {
        $("#nw").css("fill", "#9b9090");
        $("#nw1").css("fill", "#9b9090");
        $("#nw2").css("fill", "#9b9090");
        $("#nw3").css("fill", "#9b9090");
    }
    if(wu_kwei=="SW")
    {
        $("#sw").css("fill", "#9b9090");
        $("#sw1").css("fill", "#9b9090");
        $("#sw2").css("fill", "#9b9090");
        $("#sw3").css("fill", "#9b9090");
        
    }

      //for who_hai
  if(who_hai=="E")
    {
        $("#e").css("fill", "#9b9090");
        $("#e1").css("fill", "#9b9090");
        $("#e2").css("fill", "#9b9090");
        $("#e3").css("fill", "#9b9090");
    }
    
    if(who_hai=="W") 
    {
        $("#w").css("fill", "#9b9090");
        $("#w1").css("fill", "#9b9090");
        $("#w2").css("fill", "#9b9090");
        $("#w3").css("fill", "#9b9090");
    }
    if(who_hai=="N")
    {
        $("#n").css("fill", "#9b9090");
        $("#n1").css("fill", "#9b9090");
        $("#n2").css("fill", "#9b9090");
        $("#n3").css("fill", "#9b9090");
    }
   
    if(who_hai=="S")
    {
        $("#s").css("fill", "#9b9090");
        $("#s1").css("fill", "#9b9090");
        $("#s2").css("fill", "#9b9090");
        $("#s3").css("fill", "#9b9090");
    }
    if(who_hai=="NE")
    {
        $("#ne").css("fill", "#9b9090");
        $("#ne1").css("fill", "#9b9090");
        $("#ne2").css("fill", "#9b9090");
        $("#ne3").css("fill", "#9b9090");
    }
    if(who_hai=="SE")
    {
        $("#se").css("fill", "#9b9090");
        $("#se1").css("fill", "#9b9090");
        $("#se2").css("fill", "#9b9090");
        $("#se3").css("fill", "#9b9090");
    }
    if(who_hai=="NW")
    {
        $("#nw").css("fill", "#9b9090");
        $("#nw1").css("fill", "#9b9090");
        $("#nw2").css("fill", "#9b9090");
        $("#nw3").css("fill", "#9b9090");
    }
    if(who_hai=="SW")
    {
        $("#sw").css("fill", "#9b9090");
        $("#sw1").css("fill", "#9b9090");
        $("#sw2").css("fill", "#9b9090");
        $("#sw3").css("fill", "#9b9090");
        
    }
});
</script> 