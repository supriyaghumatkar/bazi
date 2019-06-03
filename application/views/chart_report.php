<?php
extract($data);
extract($natalchart);
extract($daymaster);
extract($color_element);
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

            <div class="row middle-container">
                <div class="col-md-5 col-xs-5">
                    <table width="100%" class="day-master ">
                        <tr><th width="60%">DAY MASTER (SELF ELEMENT)</th><th width="40%">: <?php echo $title; ?></th></tr>
                        <tr><td>Celestial Animal</td><td>: <img class="small-sign" src="<?php echo get_assets_path().$Celestial_Animal_Icon; ?>" alt="Goat"/> <?php echo $Celestial_Animal; ?></td></tr>

                        <?php
                        $nbp_icon = explode(',', $noble_eartly_icon);
                        $nbp_text = explode(',', $noble_people);
                        ?>
                        <tr><td>Noble People</td><td>: <img class="small-sign" src="<?php echo get_assets_path() . $nbp_icon['0']; ?>" alt="<?php echo $nbp_text[0]; ?>"/> <?php echo $nbp_text[0]; ?>, <img class="small-sign" src="<?php echo get_assets_path() . $nbp_icon['1']; ?>" alt="Ox"/><?php echo $nbp_text[1]; ?></td></tr>
                        <tr><td>Intelligence</td><td>: <img class="small-sign" src="<?php echo get_assets_path() . $intelligenec_icon; ?>" alt="<?php echo $intelligenec; ?>"/> <?php echo $intelligenec; ?></td></tr>
                        <tr><td>Peach Blossom</td><td>: <img class="small-sign" src="<?php echo get_assets_path() . $peachblossom_icon; ?>" alt="<?php echo $peachblossom; ?>"/> <?php echo $peachblossom; ?></td></tr>
                        <tr><td>Sky Horse</td><td>: <img class="small-sign" src="<?php echo get_assets_path() . $sky_horse_icon; ?>" alt="<?php echo $sky_horse; ?>"/> <?php echo $sky_horse; ?></td></tr>
                        <tr><td>Solitary</td><td>: <img class="small-sign" src="<?php echo get_assets_path() . $solitary_icon; ?>" alt="<?php echo $solitary; ?>"/> <?php echo $solitary; ?></td></tr>
<!--<tr><td>Life Palace</td><td></td><td>: <img class="small-sign" src="<?php echo get_assets_path(); ?>newcssjs/img/Dog.svg" alt="Dog"/> Yang Earth Dog</td></tr>
                        <tr><td>Conception Palace</td><td></td><td>: <img class="small-sign" src="<?php echo get_assets_path(); ?>newcssjs/img/Goat.svg" alt="Goat"/> Yin Water Goat</td></tr>-->
                    </table>
					 <table width="100%" class="men-destiny">   
                                    <!-- <tr><th width="30%">QI Men DESTINY PALACE</th><th width="15%"></th>
                                    <th width="15%">Wu Yang Earth</th> -->
                                    <th width="60%">GUA NUMBER</th>
                              <th width="40%">GUA</th></tr>
                                    <tr>
                                    <!-- <td>Life Stem</td><td></td><td>: Wu</td>-->
                               <td class="mergerow" rowspan="4"><h1><?php echo $star; ?> <?php echo $color_element[0]['color']; ?> <?php echo $color_element[0]['element']; ?> </h1></td><td class="mergerow" rowspan="4"><img src="<?php echo  get_assets_path(); ?>guaimg/<?php echo $color_element[0]['gua_icon'];  ?>"><span class="gua"><?php echo $color_element[0]['gua_element']; ?></span></td></tr>
                                    <!-- <tr><td>Door of Destiny</td><td></td><td>: Death</td></tr>
                                    <tr><td>Star of Destiny</td><td></td><td>: Grain</td></tr>
                                    <tr><td>Guardian of Destiny</td><td></td><td>: Phoenix</td></tr>				 -->
                                </table>
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
                <div class="col-md-7 col-xs-7">
                
                   
                                <table width="100%" class="natal-chart natal-chart-2">   
                                    <tr>
                                        <th width="30%" colspan="3">BAZI CHART</th>
                                        <th colspan="2" width="100px"></th>
                                    </tr>
                                    <tr class="table-title">
                                        <td width="23%">Hour</td>
                                        <td width="23%" style="background: #ffebaf;">Day</td>
                                        <td width="23%">Month</td>
                                        <td width="23%">Year</td>
                                        <td></td>
                                    </tr>	
                                    <tr>
                        <td><?php if(!empty($hourse_stemicon_stem)){ ?><img src="<?php echo get_assets_path() . $hourse_stemicon_stem; ?>" alt="Yang Wood sign"/></br><?php } ?><?php echo $hourse_chinese_element_stem; ?></br><?php echo $hourse_english_element_stem; ?></td>
                                        <td style="background: #ffebaf;"><img src="<?php echo get_assets_path() . $day_stemicon_stem; ?>" alt="Yang Wood sign"/></br><?php echo $day_chinese_element_stem; ?></br><?php echo $day_english_element_stem; ?></td>
                                        <td><img src="<?php echo get_assets_path() . $month_stemicon_stem; ?>" alt="Yang Wood sign"/></br><?php echo $month_chinese_element_stem; ?></br><?php echo $month_english_element_stem; ?></td>
                                        <td><img src="<?php echo get_assets_path() . $year_stemicon_stem; ?>" alt="Yang Wood sign"/></br><?php echo $year_chinese_element_stem; ?></br><?php echo $year_english_element_stem; ?></td>
                                        <td width="10%"><div class="vertical-text">Heavenly Stems</div></td>
                                    </tr>	
                                    <tr>
                        <td><table width="100%" class="vtable"><tbody><tr><td class="vtd" width="5%"><div class="vertical-text2"><?php echo $hoursGP;?></div></td><td width="95%"><?php if(!empty($hourse_stemicon_stem)){ ?><img src="<?php echo get_assets_path() . $hourse_earthicon_earth; ?>" alt="Yang Wood sign"/></br><?php } ?><?php echo $hourse_chinese_element_earth; ?></br><?php echo $hourse_english_element_earth; ?><br/><?php echo $hourse_animal_earth; ?></td></tr></table></td>
                                        <td style="background: #ffebaf;"><table width="100%" class="vtable"><tbody><tr><td class="vtd" width="5%"><div class="vertical-text2"><?php echo $dayGP;?></div></td><td width="95%"><img src="<?php echo get_assets_path() . $day_earthicon_earth; ?>" alt="Yang Wood sign"/></br><?php echo $day_chinese_element_earth; ?></br><?php echo $day_english_element_earth; ?><br/><?php echo $day_animal_earth; ?></td></tr></table></td>
                                        <td><table width="100%" class="vtable"><tbody><tr><td class="vtd" width="5%"><div class="vertical-text2"><?php echo $monthGP;?></div></td><td width="95%"><img src="<?php echo get_assets_path() . $month_earthicon_earth; ?>" alt="Yang Wood sign"/><br/><?php echo $month_chinese_element_earth; ?></br><?php echo $month_english_element_earth; ?><br/><?php echo $month_animal_earth; ?></td></tr></table></td>
                                        <td><table width="100%" class="vtable"><tbody><tr><td class="vtd" width="5%"><div class="vertical-text2"><?php echo $yearGP;?></div></td><td width="95%"><img src="<?php echo get_assets_path() . $year_earthicon_earth; ?>" alt="Yang Wood sign"/></br><?php echo $year_chinese_element_earth; ?></br><?php echo $year_english_element_earth ?><br/><?php echo $year_animal_earth; ?></td></tr></table></td>
                                        <td width="10%"><div class="vertical-text">Earthly Branches</div></td>
                                    </tr>	
                                    <tr><td class="minisign"><?php echo $hsdiconhourse; ?><br/><?php echo $hsdhourse; ?><br><div class="extratext"><?php echo $hshe; ?><br><span><?php echo $finacialdensityHours; ?></span></div></td>
                                        <td class="minisign" style="background: #ffebaf;"><?php echo $hsdiconday; ?><br/><?php echo $hsdyday; ?><br><div class="extratext"><?php echo $hsde; ?><br><span><?php echo $finacialdensityDay;  ?></span></div></td>
                                        <td class="minisign"><?php echo $hsdiconmonth; ?><br/><?php echo $hsdymonth; ?><br><div class="extratext"><?php echo $hsme; ?><br><span><?php echo $finacialdensityMonth; ?></span></div></td>
                                        <td class="minisign"><?php echo $hsdiconyear; ?><br/><?php echo $hsdyyear; ?><br><div class="extratext"><?php echo $hsye; ?><br><span><?php echo $finacialdensityYear; ?></span></div></td>
                                        <td width="10%"><div class="vertical-text">Hidden Stems</div></td></tr>	

                                </table>	

                </div>


                <div class="col-md-12 overflow">
                    <table width="100%"> 
                        <tr>
                            <td>
                                <table width="100%" class="natal-chart">   
                                    <tr>
                                        <th width="30%" colspan="3">LUCK PILLAR</th>
                                        <th></th>
                                        <th></th>
                                        <th></th><th></th><th></th><th></th>

                                        <th></th>
                                    </tr>
                                   
                                     <?php
                                     
                                        rsort($topcountLC);
                                        $arrlength = count($topcountLC);
                                         //for slots loop
                                        for ($x1 = 0; $x1 < $arrlength; $x1++) {
                                          $j1=$topcountLC[$x1];
                                           for($i1=0;$i1<=9;$i1++)
                                           {
                                            $slots[]=$j1++;
                                           }
                                        }
                                        ?>         
                                     <?php $arrayslots=array_chunk($slots,10);
                                    
                                     for( $i=0;$i<count($arrayslots);$i++ ){
                                         //echo $age;
                                         if(in_array($age,$arrayslots[$i]))
                                         {
                                           $slotchecked=$arrayslots[$i][0];                                       
                                         }
                                     }
                                     
                                    
                                     
                                     ?>
                                    
                                   
                                    
                                    
                                    <tr>
                                        <?php           
                                        for ($x = 0; $x < $arrlength; $x++) {
                                            if(!empty($slotchecked)){
                                            if($slotchecked==$topcountLC[$x])
                                            {
                                            
                                            echo "<td style='background: #ffebaf;'>" . $topcountLC[$x] . "</td>"; 
                                            }
                                            else{
                                               
                                                echo "<td>" . $topcountLC[$x] . "</td>";  
                                             }
                                        }
                                            else{
                                               
                                               echo "<td>" . $topcountLC[$x] . "</td>";  
                                            }
                                        }
                                        ?>
                                    </tr>	

                                    <tr><?php
                                        $arryrev = array_reverse($stemLC);
                                        $arrlengthss = count($arryrev);
                                        for ($y = 0; $y < $arrlengthss; $y++) {
                                            $stemluck = explode(",", $arryrev[$y]);
                                            if(!empty($slotchecked)){ 
                                           if($slotchecked==$topcountLC[$y])
                                            { 
                                            echo "<td style='background: #ffebaf;'><img src='" . get_assets_path() . $stemluck[0] . "' style='width: 30px;color:pink'><br>" . $stemluck[1] . "<br/>" . $stemluck[2] . "</td>";
                                            }
                                            else {
                                                echo "<td><img src='" . get_assets_path() . $stemluck[0] . "' style='width: 30px;color:pink'><br>" . $stemluck[1] . "<br/>" . $stemluck[2] . "</td>";  
                                             }
                                        }
                                           else {
                                              echo "<td><img src='" . get_assets_path() . $stemluck[0] . "' style='width: 30px;color:pink'><br>" . $stemluck[1] . "<br/>" . $stemluck[2] . "</td>";  
                                           }
                                        }
                                        ?></tr>	
                                    <?php
                                    $arryrevearth = array_reverse($earthLC);
                                     $growthLP = array_reverse($growthPLP);
                                    $arrlengthsse = count($arryrevearth);
                                    for ($k = 0; $k < $arrlengthsse; $k++) {  
                                        $earthluck = explode(",", $arryrevearth[$k]);
                                        if(!empty($slotchecked)){
                                        if($slotchecked==$topcountLC[$k])
                                            { 
                                             echo "<td style='background: #ffebaf;'><table width='100%' class='vtable'><tbody><tr><td class='vtd' width='5%'><div class='vertical-text3'>".$growthLP[$k]."</div></td><td width='95%' class='scalewidth'><img src='" . get_assets_path() . $earthluck[0] . "' style='width: 30px;color:pink'><br>" . $earthluck[1]  . "<br/>" . $earthluck[3] ."<br/>" . $earthluck[2] . "</td></tr></table></td>";
                                            }
                                            else
                                            {
                                               echo "<td><table width='100%' class='vtable'><tbody><tr><td class='vtd' width='5%'><div class='vertical-text3'>".$growthLP[$k]."</div></td><td width='95%' class='scalewidth'><img src='" . get_assets_path() . $earthluck[0] . "' style='width: 30px;color:pink'><br>" . $earthluck[1] . "<br/>" . $earthluck[3] ."<br/>" . $earthluck[2] . "</td></tr></table></td>";
                                            }
                                        } 
                                            else
                                            {
                                               echo "<td><table width='100%' class='vtable'><tbody><tr><td class='vtd' width='5%'><div class='vertical-text3'>".$growthLP[$k]."</div></td><td width='95%' class='scalewidth'><img src='" . get_assets_path() . $earthluck[0] . "' style='width: 30px;color:pink'><br>" . $earthluck[1]  . "<br/>" . $earthluck[3] ."<br/>" . $earthluck[2] . "</td></tr></table></td>";
                                            }
                                    }
                                    ?>
                                    <tr  class='smallon'>
                                        <?php
                                        $arrrev = array_reverse($hiddenstemLC);
                                        $arrredata = count($arrrev);
                                        for ($j = 0; $j < $arrredata; $j++) {
                                            $earthluckHLC = explode(",", $arrrev[$j]);
                                            if(!empty($slotchecked)){
                                            if($slotchecked==$topcountLC[$j])
                                            { 
                                            echo "<td style='background: #ffebaf;'  class='minisign'>" . $earthluckHLC[0] . "<br/>" . $earthluckHLC[1] ."<br/><div class='extratext'>" . $earthluckHLC[2] ."<br><span>".$earthluckHLC[3]."</span></div></td>";
                                            }
                                            else {
                                                echo "<td class='minisign'>" . $earthluckHLC[0] . "<br/>" . $earthluckHLC[1] ."<br/><div class='extratext'>" . $earthluckHLC[2] ."<br><span>".$earthluckHLC[3]."</span></div></td>";    
                                            }
                                        }
                                            else {
                                                echo "<td class='minisign'>" . $earthluckHLC[0] . "<br/>" . $earthluckHLC[1] ."<br/><div class='extratext'>" . $earthluckHLC[2]."<br><span>".$earthluckHLC[3]."</span></div></td>";  
                                            }
                                        }
                                        ?>
                                    </tr>

                                </table>	
                            </td>				
                        </tr>
                    </table>

                </div>     
                
                <div class="col-md-12 overflow monthlyinfluence">
                    <table width="100%"> 
                        <tr>
                            <td>
                                <table width="100%" class="natal-chart">   
                                    <tr>
                                        <th width="30%" colspan="3"><?php echo date('Y') . " MONTHLY INFLUENCE"; ?></th>
                                        <th></th>
                                        <th></th>
                                        <th></th><th></th><th></th><th></th><th></th>
                                        <th></th>
                                        <th colspan="2" width="100px">Year</th>
                                    </tr>


                                    <tr>
                                        <?php
                                        $bdaymonth=date("M", strtotime($DOB));
                                        $revstartdatemonth = array_reverse($startdatemonth);
                                        $monthyear = count($revstartdatemonth);
                                        for ($a = 0; $a < $monthyear; $a++) {
                                            echo "<td>" . $revstartdatemonth[$a] . "</td>";	   
                                        }
                                        ?>
                                        <td style='background: #ffebaf;'><?php echo date('Y'); ?></td>
                                        
                                    </tr>	

                                    <tr><?php
                                        $revcurrentyearstem = array_reverse($currentyearstem);
                                        $currentannualGPD = array_reverse($currentannualGP);
                                        $revcurrentyearstemcont = count($revcurrentyearstem);
                                        for ($b = 0; $b < $revcurrentyearstemcont; $b++) {
                                            $stemmonthcy = explode(",", $revcurrentyearstem[$b]);
                                            echo "<td><img src='" . get_assets_path() . $stemmonthcy[2] . "' style='width: 30px;color:pink'><br>" . $stemmonthcy[0] . "<br/>" . $stemmonthcy[1] . "</td>";
                                        }
                                        ?> <td style='background: #ffebaf;'><img src=<?php echo get_assets_path() . $currentyearstemdicon;?>  style='color:pink'><br><?php echo $currentyearstemd; ?><br><?php echo $currentyearstemdenelement; ?></td></tr>	
                                    <?php
                                    $revcurrentyearerath = array_reverse($currentyearerath);
                                    $revcurrentyearerathcount = count($revcurrentyearerath);
                                    for ($c = 0; $c < $revcurrentyearerathcount; $c++) {
                                        $earthmonthcy = explode(",", $revcurrentyearerath[$c]);
                                        echo "<td><table width='100%' class='vtable'><tbody><tr><td class='vtd' width='5%'><div class='vertical-text2'>".$currentannualGPD[$c]."</div></td><td width='95%' class='scalewidth'><img src='" . get_assets_path() . $earthmonthcy[2] . "' style='width: 30px;color:pink'><br>" . $earthmonthcy[0] . "<br/>" . $earthmonthcy[3] ."<br/>".$earthmonthcy[1]."</td></tr></table></td>";
                                    }
                                    ?>
                                    <td style='background: #ffebaf;'><img src=<?php echo get_assets_path() . $currentyearearthdicon;?>  style='color:pink'><br><?php echo $currentyearearthd; ?><br><?php echo $currentyearearthdenelanimalement; ?><br><?php echo $currentyearearthdenelement; ?></td>

                                    <tr>
                                        <?php
                                        $revmonthpillarhiddenstem = array_reverse($monthpillarhiddenstem);
                                        $revmonthpillarhiddenstemcount = count($revmonthpillarhiddenstem);
                                        for ($j = 0; $j < $revmonthpillarhiddenstemcount; $j++) {
                                            $earthhcy = explode(",", $revmonthpillarhiddenstem[$j]);
                                            echo "<td class='smallimg minisign'  >" . $earthhcy[0] . "<br/>" . $earthhcy[1] ."<br/><div class='extratext'>". $earthhcy[2]."<br/><span>".$earthhcy[3]."</span></div></td>";
                                        }
                                        ?>
                                        <td  class='smallimg minisign' style='background: #ffebaf;'><?php echo $currentyearhiddenstemicon;  ?><br><?php echo $currentyearhiddenstemd;  ?><br><div class='extratext'><?php echo $currentyeariddenstemenelemet; ?><br><span><?php echo $finacialdensitycurrentyear; ?></span></div></td>    
                                    </tr>

                                </table>	
                            </td>				
                        </tr>
                    </table>

                </div> 
				
               <div class="col-md-12">
				  <table width="100%" > 
				 
                        <tr>
                            <td>
             <table width="100%"  class="chart-icon">
				<tr>
					<td  valign="top">
					<table width="100%">
					<tr><th> Natal Element Count Chart</th></tr>
					<tr><td>  <div class="row">
                    <?php 
                    $natal_sum=array_sum($singleelement);
                    $keys = str_replace( ' ', '', array_keys( $singleelement));
                    $resultskey = array_combine( $keys, array_values( $singleelement ) );                      
                    //For check year Element in annual count                    
                    $currentyeatstem=$currentyearstemdenelement." ".$currentyeariddenstemenelemet;
                    $currentyearelement= str_replace("Yang","",$currentyeatstem);
                    $currentyearelementY= str_replace("Yin","",$currentyearelement);
                    $yearelement= trim($currentyearelementY);
                    $yearelement= trim($currentyearelementY);
                    $yearelementarray=explode(" ",$yearelement);
            
                   $earthP=0;
                   $MetalP=0; 
                   $fireP=0; 
                   $WoodP=0; 
                   $WaterP=0;                     
                   foreach($singleelement as $key=>$singlE)  
                   {  
                    
                     $mykey=trim($key);
                     if(array_key_exists('Earth',$resultskey))
                     {
                       if($mykey=="Earth")
                       {
                           $earthP=($singlE/$natal_sum)*100;
                           
                           
                          
                       }
                    }
                    if(array_key_exists('Fire',$resultskey))
                     {
                       if($mykey=="Fire")
                       {
                           $fireP=($singlE/$natal_sum)*100;
                         
                       }
                    }
                    if(array_key_exists('Metal',$resultskey))
                    {
                       if($mykey=="Metal")
                       {
                           $MetalP=($singlE/$natal_sum)*100;
                          
                       }
                    }
                    if(array_key_exists('Wood',$resultskey))
                    {
                       if($mykey=="Wood")
                       {
                           $WoodP=($singlE/$natal_sum)*100;
                          
                       }
                    }
                    if(array_key_exists('Water',$resultskey))
                    {
                       if($mykey=="Water")
                       {
                           $WaterP=($singlE/$natal_sum)*100;
                         
                       }
                    }
                   
                   }      
                    

                    echo '<div class="col-sm-5th-1 col-xs-6 countp"><img src="'. get_assets_path().'/icons/water.png"><h3>Water</h3><div class="percent">'.round($WaterP).'%</div></div>';
                    echo ' <div class="col-sm-5th-1 col-xs-6 countp"><img src="'. get_assets_path().'/icons/fire.png"><h3>Fire</h3><div class="percent">'.round($fireP).'%</div></div>';
                    echo '<div class="col-sm-5th-1 col-xs-6 countp"><img src="'. get_assets_path().'/icons/earth.png"><h3>Earth</h3><div class="percent">'.round($earthP).'%</div></div>';
                    echo '<div class="col-sm-5th-1 col-xs-6 countp"><img src="'. get_assets_path().'/icons/wood.png"><h3>Wood</h3><div class="percent">'.round($WoodP).'%</div></div>';
                    echo '<div class="col-sm-5th-1 col-xs-6 countp"><img src="'. get_assets_path().'/icons/metal.png"><h3>Metal</h3><div class="percent">'.round($MetalP).'%</div></div>';
?>


				   </div></td></tr>
					</table>
					</td>
					
					<td valign="top" class="tab-sep">
					<table width="100%">
					<tr><th>Annual Element Count Chart</th></tr>
					<tr><td>  <div class="row">
					
                    <?php 
                    $annual_sum=array_sum($annualelementcout);
                    $keysA = str_replace( ' ', '', array_keys($annualelementcout));
                    $resultskeyA = array_combine( $keysA, array_values($annualelementcout));
                    $earthA=0;
                   $MetalA=0; 
                   $fireA=0; 
                   $WoodA=0; 
                   $WaterA=0;     

                   foreach($annualelementcout as $keyA=>$singlA)  
                   {  
                     $mykeyA=trim($keyA);


                     if(array_key_exists('Earth',$resultskeyA))
                     {
                       if($mykeyA=="Earth")
                       {

                           
                           if(in_array('Earth',$yearelementarray))
                           {
                              $earthA= $earthP + 20;
                        
                            }
                            else
                            {
                                $earthA=($singlA/$annual_sum)*100;
                            }
                           
                       }
                    }
                    if(array_key_exists('Fire',$resultskeyA))
                    {
                       if($mykeyA=="Fire")
                       {
                           
                            if(in_array('Fire',$yearelementarray))
                             {
                              $fireA= $FireP + 20;
                            }
                            else
                            {
                                $fireA=($singlA/$annual_sum)*100;
                            }
                          
                       }
                    }
                    if(array_key_exists('Metal',$resultskeyA))
                    {
                       if($mykeyA=="Metal")
                       {
                           
                           if(in_array('Metal',$yearelementarray))
                             {
                              $MetalA= $MetalP + 20;
                            }
                            else
                            {
                                $MetalA=($singlA/$annual_sum)*100;
                            }
                          
                       }
                    } 
                    if(array_key_exists('Wood',$resultskeyA))
                    {
                       if($mykeyA=="Wood")
                       {
                          
                           if(in_array('Wood',$yearelementarray))
                           {
                            $WoodA= $WoodP + 20;
                          }
                          else
                          {
                            $WoodA=($singlA/$annual_sum)*100;
                          }
                          
                       }
                    }
                    if(array_key_exists('Water',$resultskeyA))
                    {
                       if($mykeyA=="Water")
                       {
                         
                        if(in_array('Water',$yearelementarray))
                         {
                            $WaterA= $WaterP + 20;
                          }
                          else
                          {
                            $WaterA=($singlA/$annual_sum)*100;
                          }
                          
                       }
                    }
                   } 
                   echo '<div class="col-sm-5th-1 col-xs-6 countp"><img src="'. get_assets_path().'/icons/water.png"><h3>Water</h3><div class="percent">'.round($WaterA).'%</div></div>';
                   echo ' <div class="col-sm-5th-1 col-xs-6 countp"><img src="'. get_assets_path().'/icons/fire.png"><h3>Fire</h3><div class="percent">'.round($fireA).'%</div></div>';
                   echo '<div class="col-sm-5th-1 col-xs-6 countp"><img src="'. get_assets_path().'/icons/earth.png"><h3>Earth</h3><div class="percent">'.round($earthA).'%</div></div>';
                   echo '<div class="col-sm-5th-1 col-xs-6 countp"><img src="'. get_assets_path().'/icons/wood.png"><h3>Wood</h3><div class="percent">'.round($WoodA).'%</div></div>';
                   echo '<div class="col-sm-5th-1 col-xs-6 countp"><img src="'. get_assets_path().'/icons/metal.png"><h3>Metal</h3><div class="percent">'.round($MetalA).'%</div></div>';
                   
                    ?>     
				   </div></td></tr>
					</table>
					</td>
				</tr>
			 </table>
					
                   <!-- <div id="natalpiechart"></div>--> 
				   
				
				  </td>
				  </tr>
				  </table>
                     
                     
                </div>
                <div class="col-md-12">
                    <div>
                       <?php 
                     
                     $precentage=0;
                     $precentageAN=0;
                     $precentageB=0;
                     $precentageANB=0;
                     $fin=0;

                     //For check year Element in annual count                    
                    $currentyeatstemPS=$currentyearstemd." ".$currentyearhiddenstemd;  
                    $yearelementarrayPS=explode(" ",$currentyeatstemPS);
                    $allarrayement=array_merge($stemearraywithoutday,$hday);
                   foreach($stemelementPS as $val)
                                {
								$descFD=explode(',',$finacila_density[$fin]); 
   
                               if(in_array($val['chinese_element'],$hday))
                                {
                                    
                                    
                                      $precentage=100;
                                      $precentageB=100;
                                }
                        
                              elseif(!in_array($val['chinese_element'],$hday))
                                {
                                    
                                  $indexes = array_keys($stemearraywithoutday,$val['chinese_element']); //array(0, 1)
                                  $countother= count($indexes); 
                                   

                                  if($countother >= 1 && $countother <= 2)
                                  { 
                                      $precentage=40;
                                      $precentageB=40;
                                  }
                                 else if($countother == 3)
                                  {
                                     $precentage=45; 
                                     $precentageB=45;   
                                  } 
                                  elseif($countother > 3)
                                  {
                                      $precentage=70;  
                                      $precentageB=70;  
                                  }
                                
                                elseif($countother == 0) { 
                                    $precentage=0;
                                    $precentageB=10;
                                }
                            }
                                //for Annual coding start
                                $indexes = array_keys($allarrayement,$val['chinese_element']); //array(0, 1)
                                  $countother= count($indexes); 
                                  if(in_array($val['chinese_element'],$hday))
                                  {  
                                      $precentageAN=100;
                                      $precentageANB=100;
                                  }
                          
                                 else if($countother >= 1 && $countother <= 2)
                                  {
                                    if(in_array($val['chinese_element'],$yearelementarrayPS)) 
                                        {
                                            $precentageAN=40+30;
                                            $precentageANB=40+30;
                                            $precentage=$precentage + 10;  
                                            $precentageB=$precentageB + 10;
                                        }
                                       else
                                        {
                                             $precentageAN=40;
                                             $precentageANB=40;
                                        }
                                  }
                                 elseif($countother == 3)
                                  {
                                    if(in_array($val['chinese_element'],$yearelementarrayPS)) 
                                    {
                                        $precentageAN=45+30;
                                        $precentageANB=45+30;

                                        $precentage=$precentage + 10;  
                                        $precentageB=$precentageB + 10;
                                    }
                                   else
                                    {
                                     $precentageAN=45; 
                                     $precentageANB=45;   
                                    }
                                  } 
                                  elseif($countother > 3)
                                  {
                                    if(in_array($val['chinese_element'],$yearelementarrayPS)) 
                                    {
                                        $precentageAN=70+20;
                                        $precentageANB=70+20;

                                        $precentage=$precentage + 10;  
                                        $precentageB=$precentageB + 10;
                                    }
                                   else
                                    {
                                      $precentageAN=70;  
                                      $precentageANB=70; 


                                    } 
                                  }
                                
                                else if($countother == 0) {
                                    $precentageAN=0;
                                    $precentageANB=10;
                                }
									
								$elementarray_Natal[]=$precentage.",".$val['chinese_element'].",".$val['chinese_icon'].",".$descFD[0].",".$precentageB.",".$precentageAN.",".$precentageANB;
							
                                $fin++;
                                }
                                 echo '<table width="100%" class="profile-strength">';
                                  echo '<tr>
                                        <th width="30%" colspan="3">Profile Strength</th>
                                        <th>Natal</th>
                                        <th>Annual</th>
                                    </tr>';
								$elemN=$elementarray_Natal;
										arsort($elemN,SORT_NUMERIC);
										foreach($elemN as $x_value)
										   {
												 $ementB=explode(",",$x_value);
												 echo '<tr>';   
												 echo '<td>'.$ementB[1].'</td>';
												 echo '<td><img src="'.get_assets_path().$ementB[2].'" style="width: 30px;"/></td>';
												 echo '<td>'.$ementB[3].'</td>';    

												echo '<td><div class="progress">
												<div class="progress-bar bg-success pinkbg white" style="width:'.$ementB[4].'%;" >'.$ementB[0].'%</div>
											  </div></td>';   

												echo '<td><div class="progress">
														<div class="progress-bar bg-warning pinkbg white" style="width:'.$ementB[6].'%;" >'.$ementB[5].'%</div>
													 </div></td></tr>';
											  
										   }
                              
                                echo '</table>';
                           ?> 
                    </div>
                </div>
            </div>
<!-- footer only for print desclaimer -->
    <div class="footer display-print">
        <div class="copyright">
            <p>Copyright &copy; 2019 SHARMILA MOHANAN BAZI APP All Right Reserved.</p>
        </div>
    </div>
    <!-- //footer -->
        </div>
      </div>
    </body>  
    <?php
   //echo "<pre>";
  // print_r($data);
    ?>
    <!-- Optional JavaScript -->
    <!-- jQuery first, then Popper.js, then Bootstrap JS -->
    <script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.3/umd/popper.min.js" integrity="sha384-ZMP7rVo3mIykV+2+9J3UJ46jBk0WLaUAdn689aCwoqbBJiSnjAK/l8WvCWPIPm49" crossorigin="anonymous"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/js/bootstrap.min.js" integrity="sha384-ChfqqxuZUCnJSK3+MXmPNIyE6ZbWh2IMqE241rYiqJxyMiZ6OW/JmZQ5stwEULTy" crossorigin="anonymous"></script>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.0/js/bootstrap.min.js"></script>
    <!-- <script src="<?php echo get_assets_path(); ?>newcssjs/js/loader.js"></script> -->
    
   <script type="text/javascript">
function printDiv() {
    var printContents = document.getElementById('printableArea').innerHTML;
    var originalContents = document.body.innerHTML;
    document.body.innerHTML = printContents;
    window.print();
    document.body.innerHTML = originalContents;
}
</script> 
</html>
