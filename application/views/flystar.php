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
      <div class="container-fluid" >
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
            <h2>Flying Star</h2>
<form id="flyingstar" class="fiyingstar" method="post" action="#" role="form">    
  <span id="errord" style="color:red"></span>        
<table class="table table-bordered" style="text-align:center">
  <thead>
    <tr>
      <th scope="col">Year</th>
      <th scope="col">Period</th>
      <th scope="col">Facing</th>
      <th scope="col"></th>
    </tr>
  </thead>
  <tbody>
    <tr>
  
<td><select id="Year" name="Year" style="height: 30px;" required>
<option selected="selected" value="">Select Year Of Completion</option>
<option value="2023">2023</option>
<option value="2022">2022</option>
<option value="2021">2021</option>
<option value="2020">2020</option>
<option value="2019">2019</option>
<option value="2018">2018</option>
<option value="2017">2017</option>
<option value="2016">2016</option>
<option value="2015">2015</option>
<option value="2014">2014</option>
<option value="2013">2013</option>
<option value="2012">2012</option>
<option value="2011">2011</option>
<option value="2010">2010</option>
<option value="2009">2009</option>
<option value="2008">2008</option>
<option value="2007">2007</option>
<option value="2006">2006</option>
<option value="2005">2005</option>
<option value="2004">2004</option>
<option value="2003">2003</option>
<option value="2002">2002</option>
<option value="2001">2001</option>
<option value="2000">2000</option>
<option value="1999">1999</option>
<option value="1998">1998</option>
<option value="1997">1997</option>
<option value="1996">1996</option>
<option value="1995">1995</option>
<option value="1994">1994</option>
<option value="1993">1993</option>
<option value="1992">1992</option>
<option value="1991">1991</option>
<option value="1990">1990</option>
<option value="1989">1989</option>
<option value="1988">1988</option>
<option value="1987">1987</option>
<option value="1986">1986</option>
<option value="1985">1985</option>
<option value="1984">1984</option>
<option value="1983">1983</option>
<option value="1982">1982</option>
<option value="1981">1981</option>
<option value="1980">1980</option>
</select></td>

      <td><select id="Period" name="Period" style="height: 30px; padding-left: 3px;" required>
    <option  value="">Select Period</option>
    
</select>   </td>
      <td><select id="facing" name="facing" style="height: 30px; padding-left: 3px;" required>
      <option  value="">Select Facing Direction</option>
      <option value="N1">N1  - 壬 Ren  (337.5° - 352.5°)</option>
<option  value="N2">N2  - 子 Zi (352.5° - 7.5°)</option>
<option value="N3">N3  - 癸 Gui (7.5° - 22.5°)</option>
<option value="NE1">NE1 - 丑 Chou (22.5° - 37.5°)</option>
<option value="NE2">NE2 - 艮 Gen (37.5° - 52.5°)</option>
<option value="NE3">NE3 - 寅 Yin (52.5° - 67.5°)</option>
<option value="E1">E1  - 甲 Jia (67.5° - 82.5°)</option>
<option value="E2">E2  - 卯 Mao (82.5° - 97.5°)</option>
<option value="E3">E3  - 乙 Yi (97.5° - 112.5°)</option>
<option value="SE1">SE1 - 辰 Chen (112.5° - 127.5°)</option>
<option value="SE2">SE2 - 巽 Xun (127.5° - 142.5°)</option>
<option value="SE3">SE3 - 巳 Si (142.5° - 157.5°)</option>
<option value="S1">S1  - 丙 Bing (157.5° - 172.5°)</option>
<option value="S2">S2  - 午 Wu (172.5° - 187.5°)</option>
<option value="S3">S3  - 丁 Ding (187.5° - 202.5°)</option>
<option value="SW1">SW1 - 未 Wei (202.5° - 217.5°)</option>
<option value="SW2">SW2 - 坤 Kun (217.5° - 232.5°)</option>
<option value="SW3">SW3 - 申 Shen (232.5° - 247.5°)</option>
<option value="W1">W1  - 庚 Geng (247.5° - 262.5°)</option>
<option value="W2">W2  - 酉 Dui (262.5° - 277.5°)</option>
<option value="W3">W3  - 辛 Xin (277.5° - 292.5°)</option>
<option value="NW1">NW1 - 戌 Xu (292.5° - 307.5°)</option>
<option value="NW2">NW2 - 乾 Qian (307.5° - 322.5°)</option>
<option value="NW3">NW3 - 亥 Hai (322.5° - 337.5°)</option>
</select></td>
<td><input type="button" id="btn_flyingstar" class="btn-primary" value="SUBMIT"/> </td>

    </tr>
  </tbody>
</table>
</form>

<div id="showchart"></div>

                      </div>
</div>
