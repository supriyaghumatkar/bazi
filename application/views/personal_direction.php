<?php
extract($data);
?>
<div>
		
        <div class="navbar-header  pinkbg printheader">
                     
                      <a class="navbar-brand" href="#">
                      <img class="logo" src="http://sharmilamohanan.com/bazi/assets/images/logo_gold.png">
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
         
         <div class="container min-hegt" >
          <div class="main-containerbox">
            <h2>PERSONAL DIRECTION REPORT</h2>
            <style>
            #chakra{-webkit-transition: all 1s ease-in;
                    -moz-transition: all 2.5s ease-in;
                    -ms-transition: all 2.5s ease-in;
                    -o-transition: all 2.5s ease-in;
                    transition: all 2.5s ease-in;transform:rotate(0deg);}
            </style>
            <div id="chakra" class="chakra"><?php $this->load->view('svg.php');?></div>
            <span><button class="btn btn-sm"  style="background-color:#44b20b;"></button> </span>: Favrable Direction
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

 $("#chakra").css("transform", "rotate(180deg)");

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
       // $("#chakra").css("transform", "rotate(85deg)");
        $("#e").css("fill", "#23e014");
        $("#e1").css("fill", "#23e014");
        $("#e2").css("fill", "#23e014");
        $("#e3").css("fill", "#23e014");

       
    }
    
    if(sheng_chi=="W") 
    {
       // $("#chakra").css("transform", "rotate(267deg)");
        $("#w").css("fill", "#23e014");
        $("#w1").css("fill", "#23e014");
        $("#w2").css("fill", "#23e014");
        $("#w3").css("fill", "#23e014");


    }
    if(sheng_chi=="N")
    {
       // $("#chakra").css("transform", "rotate(180deg)");
        $("#n").css("fill", "#23e014");
        $("#n1").css("fill", "#23e014");
        $("#n2").css("fill", "#23e014");
        $("#n3").css("fill", "#23e014");
    }
   
    if(sheng_chi=="S")
    {
        //$("#chakra").css("transform", "rotate(0deg)");
        $("#s").css("fill", "#23e014");
        $("#s1").css("fill", "#23e014");
        $("#s2").css("fill", "#23e014");
        $("#s3").css("fill", "#23e014");
    }
    if(sheng_chi=="NE")
    {

       // $("#chakra").css("transform", "rotate(135deg)");
        $("#ne").css("fill", "#23e014");
        $("#ne1").css("fill", "#23e014");
        $("#ne2").css("fill", "#23e014");
        $("#ne3").css("fill", "#23e014");
    }
    if(sheng_chi=="SE")
    {
       // $("#chakra").css("transform", "rotate(45deg)");
        $("#se").css("fill", "#23e014");
        $("#se1").css("fill", "#23e014");
        $("#se2").css("fill", "#23e014");
        $("#se3").css("fill", "#23e014");
    }
    if(sheng_chi=="NW")
    {
        //$("#chakra").css("transform", "rotate(225deg)");
        $("#nw").css("fill", "#23e014");
        $("#nw1").css("fill", "#23e014");
        $("#nw2").css("fill", "#23e014");
        $("#nw3").css("fill", "#23e014");
    }
    if(sheng_chi=="SW")
    {
        //$("#chakra").css("transform", "rotate(315deg)");
        $("#sw").css("fill", "#23e014");
        $("#sw1").css("fill", "#23e014");
        $("#sw2").css("fill", "#23e014");
        $("#sw3").css("fill", "#23e014");
        
    }
  //for tien_yee
  if(tien_yee=="E")
    {
        $("#e").css("fill", "#7f4a26");
        $("#e1").css("fill", "#7f4a26");
        $("#e2").css("fill", "#7f4a26");
        $("#e3").css("fill", "#7f4a26");
    }
    
    if(tien_yee=="W") 
    {
        $("#w").css("fill", "#7f4a26");
        $("#w1").css("fill", "#7f4a26");
        $("#w2").css("fill", "#7f4a26");
        $("#w3").css("fill", "#7f4a26");
    }
    if(tien_yee=="N")
    {
        $("#n").css("fill", "#7f4a26");
        $("#n1").css("fill", "#7f4a26");
        $("#n2").css("fill", "#7f4a26");
        $("#n3").css("fill", "#7f4a26");
    }
   
    if(tien_yee=="S")
    {
        $("#s").css("fill", "#7f4a26");
        $("#s1").css("fill", "#7f4a26");
        $("#s2").css("fill", "#7f4a26");
        $("#s3").css("fill", "#7f4a26");
    }
    if(tien_yee=="NE")
    {
        $("#ne").css("fill", "#7f4a26");
        $("#ne1").css("fill", "#7f4a26");
        $("#ne2").css("fill", "#7f4a26");
        $("#ne3").css("fill", "#7f4a26");
    }
    if(tien_yee=="SE")
    {
        $("#se").css("fill", "#7f4a26");
        $("#se1").css("fill", "#7f4a26");
        $("#se2").css("fill", "#7f4a26");
        $("#se3").css("fill", "#7f4a26");
    }
    if(tien_yee=="NW")
    {
        $("#nw").css("fill", "#7f4a26");
        $("#nw1").css("fill", "#7f4a26");
        $("#nw2").css("fill", "#7f4a26");
        $("#nw3").css("fill", "#7f4a26");
    }
    if(tien_yee=="SW")
    {
        $("#sw").css("fill", "#7f4a26");
        $("#sw1").css("fill", "#7f4a26");
        $("#sw2").css("fill", "#7f4a26");
        $("#sw3").css("fill", "#7f4a26");
        
    }

    //for yin_nien
  if(yin_nien=="E")
    {
        $("#e").css("fill", "#444444");
        $("#e1").css("fill", "#444444");
        $("#e2").css("fill", "#444444");
        $("#e3").css("fill", "#444444");
    }
    
    if(yin_nien=="W") 
    {
        $("#w").css("fill", "#444444");
        $("#w1").css("fill", "#444444");
        $("#w2").css("fill", "#444444");
        $("#w3").css("fill", "#444444");
    }
    if(yin_nien=="N")
    {
        $("#n").css("fill", "#444444");
        $("#n1").css("fill", "#444444");
        $("#n2").css("fill", "#444444");
        $("#n3").css("fill", "#444444");
    }
   
    if(yin_nien=="S")
    {
        $("#s").css("fill", "#444444");
        $("#s1").css("fill", "#444444");
        $("#s2").css("fill", "#444444");
        $("#s3").css("fill", "#444444");
    }
    if(yin_nien=="NE")
    {
        $("#ne").css("fill", "#444444");
        $("#ne1").css("fill", "#444444");
        $("#ne2").css("fill", "#444444");
        $("#ne3").css("fill", "#444444");
    }
    if(yin_nien=="SE")
    {
        $("#se").css("fill", "#444444");
        $("#se1").css("fill", "#444444");
        $("#se2").css("fill", "#444444");
        $("#se3").css("fill", "#444444");
    }
    if(yin_nien=="NW")
    {
        $("#nw").css("fill", "#444444");
        $("#nw1").css("fill", "#444444");
        $("#nw2").css("fill", "#444444");
        $("#nw3").css("fill", "#444444");
    }
    if(yin_nien=="SW")
    {
        $("#sw").css("fill", "#444444");
        $("#sw1").css("fill", "#444444");
        $("#sw2").css("fill", "#444444");
        $("#sw3").css("fill", "#444444");
        
    }

  //for fu_wei
  if(fu_wei=="E")
    {
        $("#e").css("fill", "#44b20b");
        $("#e1").css("fill", "#44b20b");
        $("#e2").css("fill", "#44b20b");
        $("#e3").css("fill", "#44b20b");
    }
    
    if(fu_wei=="W") 
    {
        $("#w").css("fill", "#44b20b");
        $("#w1").css("fill", "#44b20b");
        $("#w2").css("fill", "#44b20b");
        $("#w3").css("fill", "#44b20b");
    }
    if(fu_wei=="N")
    {
        $("#n").css("fill", "#44b20b");
        $("#n1").css("fill", "#44b20b");
        $("#n2").css("fill", "#44b20b");
        $("#n3").css("fill", "#44b20b");
    }
   
    if(fu_wei=="S")
    {
        $("#s").css("fill", "#44b20b");
        $("#s1").css("fill", "#44b20b");
        $("#s2").css("fill", "#44b20b");
        $("#s3").css("fill", "#44b20b");
    }
    if(fu_wei=="NE")
    {
        $("#ne").css("fill", "#44b20b");
        $("#ne1").css("fill", "#44b20b");
        $("#ne2").css("fill", "#44b20b");
        $("#ne3").css("fill", "#44b20b");
    }
    if(fu_wei=="SE")
    {
        $("#se").css("fill", "#44b20b");
        $("#se1").css("fill", "#44b20b");
        $("#se2").css("fill", "#44b20b");
        $("#se3").css("fill", "#44b20b");
    }
    if(fu_wei=="NW")
    {
        $("#nw").css("fill", "#44b20b");
        $("#nw1").css("fill", "#44b20b");
        $("#nw2").css("fill", "#44b20b");
        $("#nw3").css("fill", "#44b20b");
    }
    if(fu_wei=="SW")
    {
        $("#sw").css("fill", "#44b20b");
        $("#sw1").css("fill", "#44b20b");
        $("#sw2").css("fill", "#44b20b");
        $("#sw3").css("fill", "#44b20b");
        
    }
//End favorable Direction
//start unfavorable Direction

//for chueh_ming
if(chueh_ming=="E")
    {
        $("#e").css("fill", "#4c4c4c");
        $("#e1").css("fill", "#4c4c4c");
        $("#e2").css("fill", "#4c4c4c");
        $("#e3").css("fill", "#4c4c4c");
    }
    
    if(chueh_ming=="W") 
    {
        $("#w").css("fill", "#4c4c4c");
        $("#w1").css("fill", "#4c4c4c");
        $("#w2").css("fill", "#4c4c4c");
        $("#w3").css("fill", "#4c4c4c");
    }
    if(chueh_ming=="N")
    {
        $("#n").css("fill", "#4c4c4c");
        $("#n1").css("fill", "#4c4c4c");
        $("#n2").css("fill", "#4c4c4c");
        $("#n3").css("fill", "#4c4c4c");
    }
   
    if(chueh_ming=="S")
    {
        $("#s").css("fill", "#4c4c4c");
        $("#s1").css("fill", "#4c4c4c");
        $("#s2").css("fill", "#4c4c4c");
        $("#s3").css("fill", "#4c4c4c");
    }
    if(chueh_ming=="NE")
    {
        $("#ne").css("fill", "#4c4c4c");
        $("#ne1").css("fill", "#4c4c4c");
        $("#ne2").css("fill", "#4c4c4c");
        $("#ne3").css("fill", "#4c4c4c");
    }
    if(chueh_ming=="SE")
    {
        $("#se").css("fill", "#4c4c4c");
        $("#se1").css("fill", "#4c4c4c");
        $("#se2").css("fill", "#4c4c4c");
        $("#se3").css("fill", "#4c4c4c");
    }
    if(chueh_ming=="NW")
    {
        $("#nw").css("fill", "#4c4c4c");
        $("#nw1").css("fill", "#4c4c4c");
        $("#nw2").css("fill", "#4c4c4c");
        $("#nw3").css("fill", "#4c4c4c");
    }
    if(chueh_ming=="SW")
    {
        $("#sw").css("fill", "#4c4c4c");
        $("#sw1").css("fill", "#4c4c4c");
        $("#sw2").css("fill", "#4c4c4c");
        $("#sw3").css("fill", "#4c4c4c");
        
    }
  //for liu_sha
  if(liu_sha=="E")
    {
        $("#e").css("fill", "#1daadb");
        $("#e1").css("fill", "#1daadb");
        $("#e2").css("fill", "#1daadb");
        $("#e3").css("fill", "#1daadb");
    }
    
    if(liu_sha=="W") 
    {
        $("#w").css("fill", "#1daadb");
        $("#w1").css("fill", "#1daadb");
        $("#w2").css("fill", "#1daadb");
        $("#w3").css("fill", "#1daadb");
    }
    if(liu_sha=="N")
    {
        $("#n").css("fill", "#1daadb");
        $("#n1").css("fill", "#1daadb");
        $("#n2").css("fill", "#1daadb");
        $("#n3").css("fill", "#1daadb");
    }
   
    if(liu_sha=="S")
    {
        $("#s").css("fill", "#1daadb");
        $("#s1").css("fill", "#1daadb");
        $("#s2").css("fill", "#1daadb");
        $("#s3").css("fill", "#1daadb");
    }
    if(liu_sha=="NE")
    {
        $("#ne").css("fill", "#1daadb");
        $("#ne1").css("fill", "#1daadb");
        $("#ne2").css("fill", "#1daadb");
        $("#ne3").css("fill", "#1daadb");
    }
    if(liu_sha=="SE")
    {
        $("#se").css("fill", "#1daadb");
        $("#se1").css("fill", "#1daadb");
        $("#se2").css("fill", "#1daadb");
        $("#se3").css("fill", "#1daadb");
    }
    if(liu_sha=="NW")
    {
        $("#nw").css("fill", "#1daadb");
        $("#nw1").css("fill", "#1daadb");
        $("#nw2").css("fill", "#1daadb");
        $("#nw3").css("fill", "#1daadb");
    }
    if(liu_sha=="SW")
    {
        $("#sw").css("fill", "#1daadb");
        $("#sw1").css("fill", "#1daadb");
        $("#sw2").css("fill", "#1daadb");
        $("#sw3").css("fill", "#1daadb");
        
    }

   //for wu_kwei
   if(wu_kwei=="E")
    {
        $("#e").css("fill", "#ea341c");
        $("#e1").css("fill", "#ea341c");
        $("#e2").css("fill", "#ea341c");
        $("#e3").css("fill", "#ea341c");
    }
    
    if(wu_kwei=="W") 
    {
        $("#w").css("fill", "#ea341c");
        $("#w1").css("fill", "#ea341c");
        $("#w2").css("fill", "#ea341c");
        $("#w3").css("fill", "#ea341c");
    }
    if(wu_kwei=="N")
    {
        $("#n").css("fill", "#ea341c");
        $("#n1").css("fill", "#ea341c");
        $("#n2").css("fill", "#ea341c");
        $("#n3").css("fill", "#ea341c");
    }
   
    if(wu_kwei=="S")
    {
        $("#s").css("fill", "#ea341c");
        $("#s1").css("fill", "#ea341c");
        $("#s2").css("fill", "#ea341c");
        $("#s3").css("fill", "#ea341c");
    }
    if(wu_kwei=="NE")
    {
        $("#ne").css("fill", "#ea341c");
        $("#ne1").css("fill", "#ea341c");
        $("#ne2").css("fill", "#ea341c");
        $("#ne3").css("fill", "#ea341c");
    }
    if(wu_kwei=="SE")
    {
        $("#se").css("fill", "#ea341c");
        $("#se1").css("fill", "#ea341c");
        $("#se2").css("fill", "#ea341c");
        $("#se3").css("fill", "#ea341c");
    }
    if(wu_kwei=="NW")
    {
        $("#nw").css("fill", "#ea341c");
        $("#nw1").css("fill", "#ea341c");
        $("#nw2").css("fill", "#ea341c");
        $("#nw3").css("fill", "#ea341c");
    }
    if(wu_kwei=="SW")
    {
        $("#sw").css("fill", "#ea341c");
        $("#sw1").css("fill", "#ea341c");
        $("#sw2").css("fill", "#ea341c");
        $("#sw3").css("fill", "#ea341c");
        
    }

      //for who_hai
  if(who_hai=="E")
    {
        $("#e").css("fill", "#60382b");
        $("#e1").css("fill", "#60382b");
        $("#e2").css("fill", "#60382b");
        $("#e3").css("fill", "#60382b");
    }
    
    if(who_hai=="W") 
    {
        $("#w").css("fill", "#60382b");
        $("#w1").css("fill", "#60382b");
        $("#w2").css("fill", "#60382b");
        $("#w3").css("fill", "#60382b");
    }
    if(who_hai=="N")
    {
        $("#n").css("fill", "#60382b");
        $("#n1").css("fill", "#60382b");
        $("#n2").css("fill", "#60382b");
        $("#n3").css("fill", "#60382b");
    }
   
    if(who_hai=="S")
    {
        $("#s").css("fill", "#60382b");
        $("#s1").css("fill", "#60382b");
        $("#s2").css("fill", "#60382b");
        $("#s3").css("fill", "#60382b");
    }
    if(who_hai=="NE")
    {
        $("#ne").css("fill", "#60382b");
        $("#ne1").css("fill", "#60382b");
        $("#ne2").css("fill", "#60382b");
        $("#ne3").css("fill", "#60382b");
    }
    if(who_hai=="SE")
    {
        $("#se").css("fill", "#60382b");
        $("#se1").css("fill", "#60382b");
        $("#se2").css("fill", "#60382b");
        $("#se3").css("fill", "#60382b");
    }
    if(who_hai=="NW")
    {
        $("#nw").css("fill", "#60382b");
        $("#nw1").css("fill", "#60382b");
        $("#nw2").css("fill", "#60382b");
        $("#nw3").css("fill", "#60382b");
    }
    if(who_hai=="SW")
    {
        $("#sw").css("fill", "#60382b");
        $("#sw1").css("fill", "#60382b");
        $("#sw2").css("fill", "#60382b");
        $("#sw3").css("fill", "#60382b");
        
    }
});



</script> 