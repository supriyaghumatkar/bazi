<?php

(defined('BASEPATH')) OR exit('No direct script access allowed');
/**
 * Description of site
 *
 * @author Harshal Patil
 * This is controller file for Login to dashboard
 * 
 */
//include Rest Controller library
require APPPATH . '/libraries/REST.php';

class Chart extends REST_Controller {

    function __construct() {
        parent::__construct();
    }

    // Student Registration 
    public function fensui_chart_personal_detail_post() {
        $FirstName = $this->input->post('FirstName');
        $LastName = $this->input->post('LastName');
        $birttdate = date('Y-m-d',strtotime($this->input->post('birttdate')));
        $birthtime = $this->input->post('birthtime');
        $gender = $this->input->post('gender');
        $DNbirthtime = $this->input->post('DNbirthtime');

        $arrayrelpace = array(
            'Yang' => '+',
            'Yin' => '-'
        );
        
        $stem_initial = 2;
        $earth_initial = 10;
        $initialdate = '1925-01-01';
        $targetdate = date('Y-m-d', strtotime($birttdate));

        $date1 = date_create($initialdate);
        $date2 = date_create($targetdate);
        $diff = date_diff($date1, $date2);
        $datedifference = $diff->format("%a") + 1;
        $day_number = $datedifference;

        //For Day
        $hevenly_stems = ($day_number % 10) - 1 + $stem_initial;
        if ($hevenly_stems > 10) {     
            $hevenly_stems = $hevenly_stems % 10;
        }

        $strem = $this->heavenly_stem_by_id_get($hevenly_stems);

        $earthly_branches = ($day_number % 12) - 1 + $earth_initial;
        if ($earthly_branches > 12) {
            $earthly_branches = $earthly_branches % 12;
        }
        $earth = $this->earthly_branches_by_id_get($earthly_branches);

        $hiddenstemday = $this->hidden_stems_get($earth[0]['animal_chinese_element']);

        $hiddenstemdaydata = $hiddenstemday[0]['hidden_stems'];
        $hiddenstemiconday = $hiddenstemday[0]['icon'];
        $hsdd = explode(',', $hiddenstemdaydata);
        $hsdicond = explode(',', $hiddenstemiconday);
        $countday = count($hsdd);
        $hsdiconday = "";
        if ($countday == 3) {
            
            $hsdyday = $hsdd[0] . "  " . $hsdd[1] . "  " . $hsdd[2];         
            $enelname1=$this->heavenly_stem_by_name_get($hsdd[0]);
            $enelname2=$this->heavenly_stem_by_name_get($hsdd[1]);
            $enelname3=$this->heavenly_stem_by_name_get($hsdd[2]);
            $hsdesting=strtr($enelname1[0]['english_element']." ".$enelname2[0]['english_element']." ".$enelname2[0]['english_element'],$arrayrelpace);
            $hsde= array($enelname1[0]['english_element'],$enelname2[0]['english_element'],$enelname3[0]['english_element']);
            $hsdiconday .= "<img src='" . get_assets_path() . $hsdicond[0] . "' style='width: 30px;color:pink'> <img src='" . get_assets_path() . $hsdicond[1] . "' style='width: 30px;color:pink'><img src='" . get_assets_path() . $hsdicond[2] . "' style='width:30px;'>";
            //for 10 gods 
            $finacila_density1= $this->financial_density_get($strem[0]['chinese_element'],$enelname1[0]['english_element']);
            $finacila_density2= $this->financial_density_get($strem[0]['chinese_element'],$enelname2[0]['english_element']);
            $finacila_density3= $this->financial_density_get($strem[0]['chinese_element'],$enelname3[0]['english_element']);
            $finacialdensityDayE1=explode(',',$finacila_density1[0][$strem[0]['chinese_element']]);
            $finacialdensityDayE2=explode(',',$finacila_density2[0][$strem[0]['chinese_element']]);
            $finacialdensityDayE3=explode(',',$finacila_density3[0][$strem[0]['chinese_element']]);
            $finacialdensityDay= $finacialdensityDayE1[1]."  ".$finacialdensityDayE2[1]." ".$finacialdensityDayE3[1];
           

        } else if ($countday == 2) {

            $hsdyday = $hsdd[0] . " " . $hsdd[1];
            $enelname1=$this->heavenly_stem_by_name_get($hsdd[0]);
            $enelname2=$this->heavenly_stem_by_name_get($hsdd[1]);
            $hsdesting=strtr($enelname1[0]['english_element']." ".$enelname2[0]['english_element'],$arrayrelpace);
            $hsde= array($enelname1[0]['english_element'],$enelname2[0]['english_element']);
            $hsdiconday .= "<img src='" . get_assets_path() . $hsdicond[0] . "' style='width: 30px;color:pink'> <img src='" . get_assets_path() . $hsdicond[1] . "' style='width: 30px;color:pink'>";
            //for 10 gods 
            $finacila_density1= $this->financial_density_get($strem[0]['chinese_element'],$enelname1[0]['english_element']);
            $finacila_density2= $this->financial_density_get($strem[0]['chinese_element'],$enelname2[0]['english_element']);
            $finacialdensityDayE1=explode(',',$finacila_density1[0][$strem[0]['chinese_element']]);
            $finacialdensityDayE2=explode(',',$finacila_density2[0][$strem[0]['chinese_element']]);
            $finacialdensityDay= $finacialdensityDayE1[1]." ".$finacialdensityDayE2[1];

        } else {
            $hsdyday = $hsdd[0];
            $enelname1=$this->heavenly_stem_by_name_get($hsdd[0]);
            $hsdesting=strtr($enelname1[0]['english_element'],$arrayrelpace);
            $hsde= array($enelname1[0]['english_element']);
            $hsdiconday .= "<img src='" . get_assets_path() . $hsdicond[0] . "' style='width: 30px;color:pink'>";
            //for 10 gods 
            $finacila_density1= $this->financial_density_get($strem[0]['chinese_element'],$enelname1[0]['english_element']);
            $finacialdensityDayE1=explode(',',$finacila_density1[0][$strem[0]['chinese_element']]);    
            $finacialdensityDay= $finacialdensityDayE1[1];
        }

        //For Hours
       
        if(empty($DNbirthtime) && $DNbirthtime!="NoTime")
        {
        
        $stemelement = $strem[0]['chinese_element'];
        $times = date("H:i", strtotime($birthtime));
        $timeshours = date("H", strtotime($birthtime));
        $timeslot = explode(':', $times);
        $hours = $timeslot[0];
        $minits = $timeslot[1];
        if ($minits == 0) {
           
            $where = array('timesslot' => $hours);
            $row = $this->query->get_details('*', 'hours_temp', $where);
//log_message("error",$this->db->last_query());
            $houranimal = $row[0]['ch_animal'];
        } else {

            $where = array('timesslot' => $hours);
            $row = $this->query->get_details('*', 'hours_temp', $where);
            $houranimal = $row[0]['ch_animal'];
        } 
        // log_message("error",$timeshours);
        if($timeshours >=23 || $timeshours == 00 ||  $timeshours <= 01)
        {
            //$where1 = array('col' => $houranimal);
            $hourfirst = $this->query->get_details($stemelement, ' day_stem_hours');
           // log_message("error",$this->db->last_query());
        }
        else{
            $where1 = array('col' => $houranimal);
            $hourfirst = $this->query->get_details($stemelement, 'day_stem', $where1);
        }
        
       

        $stemenname = $this->heavenly_stem_by_name_get($hourfirst[0][$stemelement]);
        $chiniesicon = base_url() . $stemenname[0]['chinese_icon'];

        $earthmename = $this->earthly_branches_by_name_get($houranimal);
        $hiddenstemhourse = $this->hidden_stems_get($earthmename[0]['animal_chinese_element']);



        $hiddenstemhoursedata = $hiddenstemhourse[0]['hidden_stems'];
        $hiddenstemiconhourse = $hiddenstemhourse[0]['icon'];
        $hsdh = explode(',', $hiddenstemhoursedata);
        $hsdiconh = explode(',', $hiddenstemiconhourse);
        $counthourse = count($hsdh);
        $hsdiconhourse = "";
        if ($counthourse == 3) {
            $hsdhourse = $hsdh[0] . "  " . $hsdh[1] . "  " . $hsdh[2];
            $enelname4=$this->heavenly_stem_by_name_get($hsdh[0]);
            $enelname5=$this->heavenly_stem_by_name_get($hsdh[1]);
            $enelname6=$this->heavenly_stem_by_name_get($hsdh[2]);
            $hshestring= strtr($enelname4[0]['english_element']." ".$enelname5[0]['english_element']." ".$enelname6[0]['english_element'],$arrayrelpace);
            $hshe= array($enelname4[0]['english_element'],$enelname5[0]['english_element'],$enelname6[0]['english_element']);
            $hsdiconhourse .= "<img src='" . get_assets_path() . $hsdiconh[0] . "' style='width: 30px;color:pink'> <img src='" . get_assets_path() . $hsdiconh[1] . "' style='width: 30px;color:pink'><img src='" . get_assets_path() . $hsdiconh[2] . "' style='width:30px;'>";

             //for 10 gods 
             $finacila_density4= $this->financial_density_get($strem[0]['chinese_element'],$enelname4[0]['english_element']);
             $finacila_density5= $this->financial_density_get($strem[0]['chinese_element'],$enelname5[0]['english_element']);
             $finacila_density6= $this->financial_density_get($strem[0]['chinese_element'],$enelname6[0]['english_element']);
             $finacialdensityHoursE1=explode(',',$finacila_density4[0][$strem[0]['chinese_element']]);
             $finacialdensityHoursE2=explode(',',$finacila_density5[0][$strem[0]['chinese_element']]);
             $finacialdensityHoursE3=explode(',',$finacila_density6[0][$strem[0]['chinese_element']]);
             $finacialdensityHours=  $finacialdensityHoursE1[1]." ".$finacialdensityHoursE2[1]." ". $finacialdensityHoursE3[1];


        } else if ($counthourse == 2) {

            $hsdhourse = $hsdh[0] . " " . $hsdh[1];
            $enelname4=$this->heavenly_stem_by_name_get($hsdh[0]);
            $enelname5=$this->heavenly_stem_by_name_get($hsdh[1]);
            $hshestring= strtr($enelname4[0]['english_element']." ".$enelname5[0]['english_element'],$arrayrelpace);
            $hshe= array($enelname4[0]['english_element'],$enelname5[0]['english_element']);
            $hsdiconhourse .= "<img src='" . get_assets_path() . $hsdiconh[0] . "' style='width: 30px;color:pink'> <img src='" . get_assets_path() . $hsdiconh[1] . "' style='width: 30px;color:pink'>";

             //for 10 gods 
             $finacila_density4= $this->financial_density_get($strem[0]['chinese_element'],$enelname4[0]['english_element']);
             $finacila_density5= $this->financial_density_get($strem[0]['chinese_element'],$enelname5[0]['english_element']);
            
             $finacialdensityHoursE1=explode(',',$finacila_density4[0][$strem[0]['chinese_element']]);
             $finacialdensityHoursE2=explode(',',$finacila_density5[0][$strem[0]['chinese_element']]);
             $finacialdensityHours=  $finacialdensityHoursE1[1]." ".$finacialdensityHoursE2[1];

        } else {
            $hsdhourse = $hsdh[0];
            $enelname4=$this->heavenly_stem_by_name_get($hsdh[0]);
            $hshestring= strtr($enelname4[0]['english_element'],$arrayrelpace);
            $hshe= array($enelname4[0]['english_element']);
            $hsdiconhourse .= "<img src='" . get_assets_path() . $hsdiconh[0] . "' style='width: 30px;color:pink'>";

             //for 10 gods 
             $finacila_density4= $this->financial_density_get($strem[0]['chinese_element'],$enelname4[0]['english_element']);
             $finacialdensityHoursE1=explode(',',$finacila_density4[0][$strem[0]['chinese_element']]);
             $finacialdensityHours=  $finacialdensityHoursE1[1];
        }
    }
        //For Year				

        $initial_year = 1925;
        $initial_stem = 2;
        $initial_earth = 2;
        $dob_year = date('Y', strtotime($targetdate));
        $stemyear = ($dob_year - $initial_year) % 10 + $initial_stem;
        if ($stemyear > 10) {
            $stemyear = $stemyear % 10;
        }

        $stemyearqu = $this->heavenly_stem_by_id_get($stemyear);

        $earthyear = ($dob_year - $initial_year) % 12 + $initial_earth;
        if ($earthyear > 12) {
            $earthyear = $earthyear % 12;
        }


        $earthyear = $this->earthly_branches_by_id_get($earthyear);


        $hiddenstemyear = $this->hidden_stems_get($earthyear[0]['animal_chinese_element']);

        $hiddenstemyeardata = $hiddenstemyear[0]['hidden_stems'];
        $hiddenstemicon = $hiddenstemyear[0]['icon'];
        $hsdy = explode(',', $hiddenstemyeardata);
        $hsdicony = explode(',', $hiddenstemicon);
        $countyear = count($hsdy);
        $hsdiconyear = "";
        if ($countyear == 3) {
            $hsdyyear = $hsdy[0] . "  " . $hsdy[1] . "  " . $hsdy[2];
            $enelname7=$this->heavenly_stem_by_name_get($hsdy[0]);
            $enelname8=$this->heavenly_stem_by_name_get($hsdy[1]);
            $enelname9=$this->heavenly_stem_by_name_get($hsdy[2]);
            $hsyestring= strtr($enelname7[0]['english_element']." ".$enelname8[0]['english_element']." ".$enelname9[0]['english_element'],$arrayrelpace);;
            $hsye= array($enelname7[0]['english_element'],$enelname8[0]['english_element'],$enelname9[0]['english_element']);
            $hsdiconyear .= "<img src='" . get_assets_path() . $hsdicony[0] . "' style='width: 30px;color:pink'> <img src='" . get_assets_path() . $hsdicony[1] . "' style='width: 30px;color:pink'><img src='" . get_assets_path() . $hsdicony[2] . "' style='width:30px;'>";

             //for 10 gods 
             $finacila_density7= $this->financial_density_get($strem[0]['chinese_element'],$enelname7[0]['english_element']);
             $finacila_density8= $this->financial_density_get($strem[0]['chinese_element'],$enelname8[0]['english_element']);
             $finacila_density9= $this->financial_density_get($strem[0]['chinese_element'],$enelname9[0]['english_element']);
             $finacialdensityYearE1=explode(',',$finacila_density7[0][$strem[0]['chinese_element']]);
             $finacialdensityYearE2=explode(',',$finacila_density8[0][$strem[0]['chinese_element']]);
             $finacialdensityYearE3=explode(',',$finacila_density9[0][$strem[0]['chinese_element']]);
             $finacialdensityYear=  $finacialdensityYearE1[1]." ".$finacialdensityYearE2[1]." ". $finacialdensityYearE3[1];



        } else if ($countyear == 2) {

            $hsdyyear = $hsdy[0] . " " . $hsdy[1];
            $enelname7=$this->heavenly_stem_by_name_get($hsdy[0]);
            $enelname8=$this->heavenly_stem_by_name_get($hsdy[1]);
            $hsyestring= strtr($enelname7[0]['english_element']." ".$enelname8[0]['english_element'],$arrayrelpace);
            $hsye= array($enelname7[0]['english_element'],$enelname8[0]['english_element']);
            $hsdiconyear .= "<img src='" . get_assets_path() . $hsdicony[0] . "' style='width: 30px;color:pink'> <img src='" . get_assets_path() . $hsdicony[1] . "' style='width: 30px;color:pink'>";

             //for 10 gods 
             $finacila_density7= $this->financial_density_get($strem[0]['chinese_element'],$enelname7[0]['english_element']);
             $finacila_density8= $this->financial_density_get($strem[0]['chinese_element'],$enelname8[0]['english_element']);
             $finacialdensityYearE1=explode(',',$finacila_density7[0][$strem[0]['chinese_element']]);
             $finacialdensityYearE2=explode(',',$finacila_density8[0][$strem[0]['chinese_element']]);
             $finacialdensityYear=  $finacialdensityYearE1[1]." ".$finacialdensityYearE2[1];

        } else {
            $hsdyyear = $hsdy[0];
            $enelname7=$this->heavenly_stem_by_name_get($hsdy[0]);
            $hsyestring= strtr($enelname7[0]['english_element'],$arrayrelpace);
            $hsye= array($enelname7[0]['english_element']);
            $hsdiconyear .= "<img src='" . get_assets_path() . $hsdicony[0] . "' style='width: 30px;color:pink'>";

             //for 10 gods 
             $finacila_density7= $this->financial_density_get($strem[0]['chinese_element'],$enelname7[0]['english_element']);
             $finacialdensityYearE1=explode(',',$finacila_density7[0][$strem[0]['chinese_element']]);
             $finacialdensityYear=  $finacialdensityYearE1[1];
        }
        
        //For Current year
        $current_year = date('Y');
        $stemcuryear = ($current_year - $initial_year) % 10 + $initial_stem;
        if ($stemcuryear > 10) {
           $stemcuryear = $stemcuryear % 10;
        }
        $stemcuryearqu = $this->heavenly_stem_by_id_get($stemcuryear);
        $earthcuryear = ($current_year - $initial_year) % 12 + $initial_earth;
        if ($earthcuryear > 12) {
            $earthcuryear = $earthcuryear % 12;
        }
        $earthcurnyear = $this->earthly_branches_by_id_get($earthcuryear);
        $hiddenstemcuryear = $this->hidden_stems_get($earthcurnyear[0]['animal_chinese_element']);

        $hiddenstemcuryeardata = $hiddenstemcuryear[0]['hidden_stems'];
        $hiddenstemcuricon = $hiddenstemcuryear[0]['icon'];
        $hsdcury = explode(',', $hiddenstemcuryeardata);
        $hsdcuricony = explode(',', $hiddenstemcuricon);
        $countcuryear = count($hsdcury);
        $hsdiconcuryear = "";
        if ($countcuryear == 3) {
            $hsdcuryyear = $hsdcury[0] . "  " . $hsdcury[1] . "  " . $hsdcury[2];
            $enelname16=$this->heavenly_stem_by_name_get($hsdcury[0]);
            $enelname17=$this->heavenly_stem_by_name_get($hsdcury[1]);
            $enelname18=$this->heavenly_stem_by_name_get($hsdcury[2]);
            $hsycurestring= strtr($enelname16[0]['english_element']." ".$enelname17[0]['english_element']." ".$enelname18[0]['english_element'],$arrayrelpace);
            $hsye= array($enelname16[0]['english_element'],$enelname17[0]['english_element'],$enelname18[0]['english_element']);
            $hsdiconcuryear .= "<img src='" . get_assets_path() . $hsdcuricony[0] . "' style='width: 30px;color:pink'> <img src='" . get_assets_path() . $hsdcuricony[1] . "' style='width: 30px;color:pink'><img src='" . get_assets_path() . $hsdcuricony[2] . "' style='width:30px;'>";

             //for 10 gods 
             $finacila_density13= $this->financial_density_get($strem[0]['chinese_element'],$enelname16[0]['english_element']);
             $finacila_density14= $this->financial_density_get($strem[0]['chinese_element'],$enelname17[0]['english_element']);
             $finacila_density15= $this->financial_density_get($strem[0]['chinese_element'],$enelname18[0]['english_element']);
             $finacialdensitycurrentyearE1=explode(',',$finacila_density13[0][$strem[0]['chinese_element']]);
             $finacialdensitycurrentyearE2=explode(',',$finacila_density14[0][$strem[0]['chinese_element']]);
             $finacialdensitycurrentyearE3=explode(',',$finacila_density15[0][$strem[0]['chinese_element']]);
             $finacialdensityMonth=  $finacialdensitycurrentyearE1[1]." ".$finacialdensitycurrentyearE2[1]." ". $finacialdensitycurrentyearE3[1];


        } else if($countcuryear == 2) {

            $hsdcuryyear = $hsdcury[0] . "  " . $hsdcury[1] ;
            $enelname16=$this->heavenly_stem_by_name_get($hsdcury[0]);
            $enelname17=$this->heavenly_stem_by_name_get($hsdcury[1]);
            $hsycurestring= strtr($enelname16[0]['english_element']." ".$enelname17[0]['english_element'],$arrayrelpace);
            $hsye= array($enelname16[0]['english_element'],$enelname17[0]['english_element']);
            $hsdiconcuryear .= "<img src='" . get_assets_path() . $hsdcuricony[0] . "' style='width: 30px;color:pink'> <img src='" . get_assets_path() . $hsdcuricony[1] . "' style='width: 30px;color:pink'>";
              //for 10 gods 
              $finacila_density13= $this->financial_density_get($strem[0]['chinese_element'],$enelname16[0]['english_element']);
              $finacila_density14= $this->financial_density_get($strem[0]['chinese_element'],$enelname17[0]['english_element']);
              $finacialdensitycurrentyearE1=explode(',',$finacila_density13[0][$strem[0]['chinese_element']]);
              $finacialdensitycurrentyearE2=explode(',',$finacila_density14[0][$strem[0]['chinese_element']]);
              $finacialdensitycurrentyear=  $finacialdensitycurrentyearE1[1]." ".$finacialdensitycurrentyearE2[1];

        } else {
           $hsdcuryyear = $hsdcury[0] ;
            $enelname16=$this->heavenly_stem_by_name_get($hsdcury[0]);
            $hsycurestring= strtr($enelname16[0]['english_element'],$arrayrelpace);
            $hsye= array($enelname16[0]['english_element']);
            $hsdiconcuryear .= "<img src='" . get_assets_path() . $hsdcuricony[0] . "' style='width: 30px;color:pink'>";
            //for 10 gods 
            $finacila_density13= $this->financial_density_get($strem[0]['chinese_element'],$enelname16[0]['english_element']);
            $finacialdensitycurrentyearE1=explode(',',$finacila_density13[0][$strem[0]['chinese_element']]);
            $finacialdensitycurrentyear=  $finacialdensitycurrentyearE1[1];

        }
        
     
        //For month
        $initial_stem_month = 3;
        $initial_earth_month = 1;
        //$dob_year=1974;
        $dob_month = date('m', strtotime($targetdate));
        $stemmonth = ((($dob_year - $initial_year) * 12) + $dob_month) % 10 + $initial_stem_month;
        if ($stemmonth > 10) {
            $stemmonth = $stemmonth % 10;
        }

        $year = date('Y', strtotime($targetdate));
        $month = strtolower(date('M', strtotime($birttdate)));

        $where4 = array('year' => $year);
        $monthbirttdate = $this->query->get_details($month, 'chinese_month_start', $where4);
        $month = strtolower(date('M', strtotime($birttdate)));
        
        if ($birttdate < $monthbirttdate[0][$month]) {
             
            $stemmonth = $stemmonth - 1;
            
        }
        if($stemmonth==0)
        {
            $stemmonth=10;
        }
        $stremmonth = $this->heavenly_stem_by_id_get($stemmonth);

        $earthmmonth = ((($dob_year - $initial_year) * 12) + $dob_month) % 12 + $initial_earth_month;
        if ($earthmmonth > 12) {
            $earthmmonth = $earthmmonth % 12;
        } 
        if ($birttdate < $monthbirttdate[0][$month]) {

            $earthmmonth = $earthmmonth - 1;
        }
        if($earthmmonth==0)
        {
            $earthmmonth=12;
        }
        $queryearthmo = $this->earthly_branches_by_id_get($earthmmonth);  
        $hiddenstemmonth = $this->hidden_stems_get($queryearthmo[0]['animal_chinese_element']);
        $hiddenstemmonthdata = $hiddenstemmonth[0]['hidden_stems'];
        $hiddenstemiconmonth = $hiddenstemmonth[0]['icon'];
        $hsdm = explode(',', $hiddenstemmonthdata);
        $hsdiconm = explode(',', $hiddenstemiconmonth);
        $countmonth = count($hsdm);
        $hsdiconmonth = "";
        if ($countmonth == 3) {
            $hsdymonth = $hsdm[0] . "  " . $hsdm[1] . "  " . $hsdm[2];
            $enelname10=$this->heavenly_stem_by_name_get($hsdm[0]);
            $enelname11=$this->heavenly_stem_by_name_get($hsdm[1]);
            $enelname12=$this->heavenly_stem_by_name_get($hsdm[2]);
            $hsmesting= strtr($enelname10[0]['english_element']." ".$enelname11[0]['english_element']." ".$enelname12[0]['english_element'],$arrayrelpace);
            $hsme= array($enelname10[0]['english_element'],$enelname11[0]['english_element'],$enelname12[0]['english_element']);
            $hsdiconmonth .= "<img src='" . get_assets_path() . $hsdiconm[0] . "' style='width: 30px;color:pink'> <img src='" . get_assets_path() . $hsdiconm[1] . "' style='width: 30px;color:pink'><img src='" . get_assets_path() . $hsdiconm[2] . "' style='width:30px;'>";

            //for 10 gods 
            $finacila_density10= $this->financial_density_get($strem[0]['chinese_element'],$enelname10[0]['english_element']);
            $finacila_density11= $this->financial_density_get($strem[0]['chinese_element'],$enelname11[0]['english_element']);
            $finacila_density12= $this->financial_density_get($strem[0]['chinese_element'],$enelname12[0]['english_element']);
            $finacialdensityMonthE1=explode(',',$finacila_density10[0][$strem[0]['chinese_element']]);
            $finacialdensityMonthE2=explode(',',$finacila_density11[0][$strem[0]['chinese_element']]);
            $finacialdensityMonthE3=explode(',',$finacila_density12[0][$strem[0]['chinese_element']]);
            $finacialdensityMonth=  $finacialdensityMonthE1[1]." ".$finacialdensityMonthE2[1]." ". $finacialdensityMonthE3[1];

        } else if ($countmonth == 2) {

            $hsdymonth = $hsdm[0] . " " . $hsdm[1];
            $enelname10=$this->heavenly_stem_by_name_get($hsdm[0]);
            $enelname11=$this->heavenly_stem_by_name_get($hsdm[1]);
             $hsmesting= strtr($enelname10[0]['english_element']." ".$enelname11[0]['english_element'],$arrayrelpace);
            $hsme= array($enelname10[0]['english_element'],$enelname11[0]['english_element']);
            $hsdiconmonth .= "<img src='" . get_assets_path() . $hsdiconm[0] . "' style='width: 30px;color:pink'><img src='" . get_assets_path() . $hsdiconm[1] . "' style='width: 30px;color:pink'>";

             //for 10 gods 
             $finacila_density10= $this->financial_density_get($strem[0]['chinese_element'],$enelname10[0]['english_element']);
             $finacila_density11= $this->financial_density_get($strem[0]['chinese_element'],$enelname11[0]['english_element']);
             $finacialdensityMonthE1=explode(',',$finacila_density10[0][$strem[0]['chinese_element']]);
             $finacialdensityMonthE2=explode(',',$finacila_density11[0][$strem[0]['chinese_element']]);
             $finacialdensityMonth=  $finacialdensityMonthE1[1]." ".$finacialdensityMonthE2[1];

        } else {
            $hsdymonth = $hsdm[0];
            $enelname10=$this->heavenly_stem_by_name_get($hsdm[0]);
            $hsmesting= strtr($enelname10[0]['english_element'],$arrayrelpace);
            $hsme= array($enelname10[0]['english_element']);
            $hsdiconmonth .= "<img src='" . get_assets_path() . $hsdiconm[0] . "' style='width: 30px;color:pink'>";

            //for 10 gods 
            $finacila_density10= $this->financial_density_get($strem[0]['chinese_element'],$enelname10[0]['english_element']);
            //log_message("error",$this->db->last_query());
            $finacialdensityMonthE1=explode(',',$finacila_density10[0][$strem[0]['chinese_element']]);
            $finacialdensityMonth=  $finacialdensityMonthE1[1];
        }
        
        //profile strength array without day element
       
        if(empty($DNbirthtime) && $DNbirthtime!="NoTime")
        {
        
            $hhourse= explode(" ", $hsdhourse);
            $hmonth= explode(" ", $hsdymonth);
            $hyear= explode(" ", $hsdyyear);
            $hday= explode(" ", $hsdyday);
            //log_message("error","zsdasdasd".$stremmonth[0]['chinese_element']);
            $stemelementprofile=array($hourfirst[0][$stemelement],$stremmonth[0]['chinese_element'],$stemyearqu[0]['chinese_element']);
            $stemelementprofilemerge= array_merge($stemelementprofile,$hmonth,$hhourse,$hyear);
            $meragearrayPS=array_filter($stemelementprofilemerge);
            $countofchinieselement= array_count_values($meragearrayPS);
        }
        else
        {
             // $hhourse= explode(" ", $hsdhourse);
             $hmonth= explode(" ", $hsdymonth);
             $hyear= explode(" ", $hsdyyear);
             $hday= explode(" ", $hsdyday);
             $stemelementprofile=array($stremmonth[0]['chinese_element'],$stemyearqu[0]['chinese_element']);
             $stemelementprofilemerge= array_merge($stemelementprofile,$hmonth,$hyear);
             $meragearrayPS=array_filter($stemelementprofilemerge);
             $countofchinieselement= array_count_values($meragearrayPS);
        }
            
       
        
        if(empty($DNbirthtime) && $DNbirthtime!="NoTime")
        {  
        //For Pie Chart Count Of Element in natal
        $countnatalchart=array($stemenname[0]['english_element'],$strem[0]['english_element'],$stremmonth[0]['english_element'],$stemyearqu[0]['english_element'],$earthmename[0]['animal_english_element'],$earth[0]['animal_english_element'],$queryearthmo[0]['animal_english_element'],$earthyear[0]['animal_english_element'],);
        $mainarraycount=array_merge($countnatalchart,$hsde,$hshe,$hsye,$hsme);
        $countnatalelement=array_count_values($mainarraycount);
        
        //for single element count
        $arraystring=implode(",",$mainarraycount);
        $singlestr=str_replace("Yang","",$arraystring);
        $singlestr1=str_replace("Yin","",$singlestr);  
        $singleelemet=explode(",",$singlestr1);
        $singlecountelement=array_count_values($singleelemet);
        
        
        //For Growth Phase Coding
       $hoursGP=$this->growth_phases_get($strem[0]['chinese_element'],$earthmename[0]['animal']);
       $dayGP=$this->growth_phases_get($strem[0]['chinese_element'],$earth[0]['animal']);
       $monthGP=$this->growth_phases_get($strem[0]['chinese_element'],$queryearthmo[0]['animal']);
       $yearGP=$this->growth_phases_get($strem[0]['chinese_element'],$earthyear[0]['animal']);
        }
        else{

                //For Pie Chart Count Of Element in natal
        $countnatalchart=array($strem[0]['english_element'],$stremmonth[0]['english_element'],$stemyearqu[0]['english_element'],$earth[0]['animal_english_element'],$queryearthmo[0]['animal_english_element'],$earthyear[0]['animal_english_element'],);
        $mainarraycount=array_merge($countnatalchart,$hsde,$hsye,$hsme);
        $countnatalelement=array_count_values($mainarraycount);
        
        //for single element count
        $arraystring=implode(",",$mainarraycount);
        $singlestr=str_replace("Yang","",$arraystring);
        $singlestr1=str_replace("Yin","",$singlestr);  
        $singleelemet=explode(",",$singlestr1);
        $singlecountelement=array_count_values($singleelemet);
        //For Growth Phase Coding
       //$hoursGP=$this->growth_phases_get($strem[0]['chinese_element'],$earthmename[0]['animal']);
       $dayGP=$this->growth_phases_get($strem[0]['chinese_element'],$earth[0]['animal']);
       $monthGP=$this->growth_phases_get($strem[0]['chinese_element'],$queryearthmo[0]['animal']);
       $yearGP=$this->growth_phases_get($strem[0]['chinese_element'],$earthyear[0]['animal']);
        }
        if(empty($DNbirthtime) && $DNbirthtime!="NoTime")
        {
         
        $natalchart = array(
            'hourse_stemicon_stem' => $stemenname[0]['chinese_icon'],
            'hourse_chinese_element_stem' => $hourfirst[0][$stemelement],
            'hourse_english_element_stem' => $stemenname[0]['english_element'],
            'day_stemicon_stem' => $strem[0]['chinese_icon'],
            'day_chinese_element_stem' => $strem[0]['chinese_element'],
            'day_english_element_stem' => $strem[0]['english_element'],
            'month_stemicon_stem' => $stremmonth[0]['chinese_icon'],
            'month_chinese_element_stem' => $stremmonth[0]['chinese_element'],
            'month_english_element_stem' => $stremmonth[0]['english_element'],
            'year_stemicon_stem' => $stemyearqu[0]['chinese_icon'],
            'year_chinese_element_stem' => $stemyearqu[0]['chinese_element'],
            'year_english_element_stem' => $stemyearqu[0]['english_element'],
            'hourse_earthicon_earth' => $earthmename[0]['animal_chinese_icon'],
            'hourse_chinese_element_earth' => $houranimal,
            'hourse_english_element_earth' => $earthmename[0]['animal_english_element'],
            'hourse_animal_earth' => $earthmename[0]['animal'],
            'day_earthicon_earth' => $earth[0]['animal_chinese_icon'],
            'day_chinese_element_earth' => $earth[0]['animal_chinese_element'],
            'day_english_element_earth' => $earth[0]['animal_english_element'],
            'day_animal_earth' => $earth[0]['animal'],
            'month_earthicon_earth' => $queryearthmo[0]['animal_chinese_icon'],
            'month_chinese_element_earth' => $queryearthmo[0]['animal_chinese_element'],
            'month_english_element_earth' => $queryearthmo[0]['animal_english_element'],
            'month_animal_earth' => $queryearthmo[0]['animal'],
            'year_earthicon_earth' => $earthyear[0]['animal_chinese_icon'],
            'year_chinese_element_earth' => $earthyear[0]['animal_chinese_element'],
            'year_english_element_earth' => $earthyear[0]['animal_english_element'],
            'year_animal_earth' => $earthyear[0]['animal'],
            'hsdiconhourse' => $hsdiconhourse,
            'hsdhourse' => $hsdhourse,
            'hsdiconday' => $hsdiconday,
            'hsdyday' => $hsdyday,
            'hsde'=>$hsdesting,
            'hshe'=>$hshestring,
            'hsye'=>$hsyestring,
            'hsme'=>$hsmesting,
            'hsdiconmonth' => $hsdiconmonth,
            'hsdymonth' => $hsdymonth,
            'hsdiconyear' => $hsdiconyear,
            'hsdyyear' => $hsdyyear,
            //'countnatalelement'=>$countnatalelement,
            'singleelement'=>$singlecountelement,
            'testvar'=> $meragearrayPS,
            'hmonth'=>array_filter($hmonth),
            'hhourse'=>array_filter($hhourse),
            'hyear'=>array_filter($hyear),
            'hday'=>array_filter($hday),
            'stemearraywithoutday'=>$meragearrayPS,
            'countofchinieselement'=>$countofchinieselement,
            'currentyearstemd'=>$stemcuryearqu[0]['chinese_element'],
            'currentyearstemdicon'=>$stemcuryearqu[0]['chinese_icon'],
            'currentyearstemdenelement'=>$stemcuryearqu[0]['english_element'],
            'currentyearearthd'=>$earthcurnyear[0]['animal_chinese_element'],
            'currentyearearthdicon'=>$earthcurnyear[0]['animal_chinese_icon'],
            'currentyearearthdenelement'=>$earthcurnyear[0]['animal_english_element'],
             'currentyearearthdenelanimalement'=>$earthcurnyear[0]['animal'],
            'currentyearhiddenstemd'=>$hsdcuryyear,
            'currentyearhiddenstemicon'=>$hsdiconcuryear,
            'currentyeariddenstemenelemet'=>$hsycurestring,
            'hoursGP'=>$hoursGP[0]['Key_2'],
            'dayGP'=>$dayGP[0]['Key_2'],
            'monthGP'=>$monthGP[0]['Key_2'],
            'yearGP'=>$yearGP[0]['Key_2'],
            'finacialdensityDay'=>$finacialdensityDay,
            'finacialdensityHours'=>$finacialdensityHours,
            'finacialdensityYear'=>$finacialdensityYear,
            'finacialdensityMonth'=>$finacialdensityMonth,
            'finacialdensitycurrentyear'=>$finacialdensitycurrentyear



       );
    }
    else
    {
        $natalchart = array(
            'hourse_stemicon_stem' => '',
            'hourse_chinese_element_stem' => '',
            'hourse_english_element_stem' =>'',
            'day_stemicon_stem' => $strem[0]['chinese_icon'],
            'day_chinese_element_stem' => $strem[0]['chinese_element'],
            'day_english_element_stem' => $strem[0]['english_element'],
            'month_stemicon_stem' => $stremmonth[0]['chinese_icon'],
            'month_chinese_element_stem' => $stremmonth[0]['chinese_element'],
            'month_english_element_stem' => $stremmonth[0]['english_element'],
            'year_stemicon_stem' => $stemyearqu[0]['chinese_icon'],
            'year_chinese_element_stem' => $stemyearqu[0]['chinese_element'],
            'year_english_element_stem' => $stemyearqu[0]['english_element'],
            'hourse_earthicon_earth' =>'',
            'hourse_chinese_element_earth' => '',
            'hourse_english_element_earth' => '',
            'hourse_animal_earth' => '',
            'day_earthicon_earth' => $earth[0]['animal_chinese_icon'],
            'day_chinese_element_earth' => $earth[0]['animal_chinese_element'],
            'day_english_element_earth' => $earth[0]['animal_english_element'],
            'day_animal_earth' => $earth[0]['animal'],
            'month_earthicon_earth' => $queryearthmo[0]['animal_chinese_icon'],
            'month_chinese_element_earth' => $queryearthmo[0]['animal_chinese_element'],
            'month_english_element_earth' => $queryearthmo[0]['animal_english_element'],
            'month_animal_earth' => $queryearthmo[0]['animal'],
            'year_earthicon_earth' => $earthyear[0]['animal_chinese_icon'],
            'year_chinese_element_earth' => $earthyear[0]['animal_chinese_element'],
            'year_english_element_earth' => $earthyear[0]['animal_english_element'],
            'year_animal_earth' => $earthyear[0]['animal'],
            'hsdiconhourse' => '',
            'hsdhourse' => '',
            'hsdiconday' => $hsdiconday,
            'hsdyday' => $hsdyday,
            'hsde'=>$hsdesting,
            'hshe'=>'',
            'hsye'=>$hsyestring,
            'hsme'=>$hsmesting,
            'hsdiconmonth' => $hsdiconmonth,
            'hsdymonth' => $hsdymonth,
            'hsdiconyear' => $hsdiconyear,
            'hsdyyear' => $hsdyyear,
            //'countnatalelement'=>$countnatalelement,
            'singleelement'=>$singlecountelement,
            'testvar'=> $meragearrayPS,
            'hmonth'=>array_filter($hmonth),
            'hhourse'=>'',
            'hyear'=>array_filter($hyear),
            'hday'=>array_filter($hday),
            'stemearraywithoutday'=>$meragearrayPS,
            'countofchinieselement'=>$countofchinieselement,
            'currentyearstemd'=>$stemcuryearqu[0]['chinese_element'],
            'currentyearstemdicon'=>$stemcuryearqu[0]['chinese_icon'],
            'currentyearstemdenelement'=>$stemcuryearqu[0]['english_element'],
            'currentyearearthd'=>$earthcurnyear[0]['animal_chinese_element'],
            'currentyearearthdicon'=>$earthcurnyear[0]['animal_chinese_icon'],
            'currentyearearthdenelement'=>$earthcurnyear[0]['animal_english_element'],
             'currentyearearthdenelanimalement'=>$earthcurnyear[0]['animal'],
            'currentyearhiddenstemd'=>$hsdcuryyear,
            'currentyearhiddenstemicon'=>$hsdiconcuryear,
            'currentyeariddenstemenelemet'=>$hsycurestring,
            'hoursGP'=>'',
            'dayGP'=>$dayGP[0]['Key_2'],
            'monthGP'=>$monthGP[0]['Key_2'],
            'yearGP'=>$yearGP[0]['Key_2'],
            'finacialdensityDay'=>$finacialdensityDay,
            'finacialdensityHours'=>'',
            'finacialdensityYear'=>$finacialdensityYear,
            'finacialdensityMonth'=>$finacialdensityMonth,
            'finacialdensitycurrentyear'=>$finacialdensitycurrentyear
       );
    }
        //Day Master 
       
        $wherenb = array('chinese_element' => $strem[0]['chinese_element']);
        $noble_people = $this->query->get_details('*','noble_people', $wherenb);
        
        $whereinte = array('day_master' => $strem[0]['chinese_element']);
        $intelligenec = $this->query->get_details('*','intelligence', $whereinte);
        
        
        $wherepeach = array('year_day_chinese' => $earth[0]['animal_chinese_element']);
        $pss = $this->query->get_details('*','peach_sky_solitary', $wherepeach);
        $pss_icon_peach = $this->earthly_branches_by_name_get($pss[0]['peach_blossom_chinese']);
        $pss_icon_sky = $this->earthly_branches_by_name_get($pss[0]['sky_horse_chinese']);
        $pss_icon_solitary = $this->earthly_branches_by_name_get($pss[0]['solitary_chinese']);
        
        //age calculation
        $dateOfBirth = date("Y-m-d", strtotime($birttdate));
        $today = date("Y-m-d");
        $diff = date_diff(date_create($dateOfBirth), date_create($today));
        $age=$diff->format('%y');
        
        
        
        
        $daymaster = array(
            'title'=>$strem[0]['chinese_element']." ".$strem[0]['english_element'],
            'name' =>ucfirst($FirstName)." ".ucfirst($LastName),
            'DOB' => $birttdate,
            'gender' => $gender,
            'birthtime' => $birthtime,
            'age'=>$age,
            'Celestial_Animal_Icon' => $earthyear[0]['animal_chinese_icon'],
            'Celestial_Animal' => $earthyear[0]['animal'],
            'noble_people'=>$noble_people[0]['english_element'],
            'noble_eartly_icon'=>$noble_people[0]['earthly_icon'],
            'intelligenec'=>$intelligenec[0]['inteligence_en_element'],
            'intelligenec_icon'=>$intelligenec[0]['intelligence_icon'],
            'peachblossom'=>$pss[0]['peach_blossom_english'],
            'peachblossom_icon'=>$pss_icon_peach[0]['animal_chinese_icon'],
            'sky_horse'=>$pss[0]['sky_horse_english'],
            'sky_horse_icon'=>$pss_icon_sky[0]['animal_chinese_icon'],
            'solitary'=>$pss[0]['solitary_english'],
            'solitary_icon'=>$pss_icon_solitary[0]['animal_chinese_icon']
        );

          //Life star coding
         $dobdate = date('Y', strtotime($birttdate));
         $sting=$this->life_star_get($dobdate,$gender);
         
       //Direction Coding 
        $favorable_direction_detail=$this->favorable_direction_get($sting);
        $unfavorable_direction_detail=$this->unfavorable_direction_get($sting);
        
        //Luck Pillar
        $stemyearluck = $stemyearqu[0]['chinese_element'];
        $day_forward_back = $stemyearqu[0]['english_element'];
        $sign_back_fow = explode(' ', $day_forward_back);

        $year = date('Y', strtotime($birttdate));

        if (($sign_back_fow[0] == 'Yin' && $gender == 'Female') || ($sign_back_fow[0] == 'Yang' && $gender == 'Male')) {

            $month = strtolower(date('M', strtotime($birttdate)));
            $where5 = array('year' => $year);
            $monthbirttdate = $this->query->get_details($month, 'chinese_month_start', $where5);

            if ($birttdate > $monthbirttdate[0][$month]) {
                
                $curmonth=strtolower(date('M',strtotime($birttdate)));
		$month=strtolower(date('M',strtotime($birttdate." +1 months")));
		if($curmonth=='dec')
		{
			$year=strtolower(date('Y',strtotime($birttdate." +1 year")));
		}
                //$month = strtolower(date('M', strtotime($birttdate . " +1 months")));
                $where5 = array('year' => $year);
                $monthbirttdate = $this->query->get_details($month, 'chinese_month_start', $where5);
            } else {
                $month = strtolower(date('M', strtotime($birttdate)));
            }
            $date11 = date_create($birttdate);
            $date22 = date_create($monthbirttdate[0][$month]);
            $diff = date_diff($date11, $date22);
            $forwarddays = $diff->format("%R%a") / 3;
            $forwardday = round($forwarddays);

            $stem_id = $stremmonth[0]['id'];
            $earth_id = $queryearthmo[0]['id'];

            for ($i = 1; $i <= 10; $i++) {
                $forarray[] = $forwardday;
                $forwardday = $forwardday + 10;
            }


            for ($i = 1; $i <= 10; $i++) {
                $stem_id++;
                if ($stem_id > 10) {
                    $stem_id = 1;
                }
                $stem_id_array[] = $stem_id;
            }

            $arryrev = $stem_id_array;
            $arrlengthss = count($arryrev);
            for ($y = 0; $y < $arrlengthss; $y++) {


                $stemluck = $this->heavenly_stem_by_id_get($arryrev[$y]);
                $luckpillarstem[] = $stemluck[0]['chinese_icon'] . "," . $stemluck[0]['chinese_element'] . "," . $stemluck[0]['english_element'];
            }


            for ($i = 1; $i <= 10; $i++) {
                $earth_id++;
                if ($earth_id > 12) {
                    $earth_id = 1;
                }
                $earth_id_array[] = $earth_id;
            }


            $arryrevearth = $earth_id_array;
            $arrlengthsse = count($arryrevearth);
            for ($k = 0; $k < $arrlengthsse; $k++) {


                $earthluck = $this->earthly_branches_by_id_get($arryrevearth[$k]);
                $luckpillarearth[] = $earthluck[0]['animal_chinese_icon'] . "," . $earthluck[0]['animal_chinese_element'] . "," . $earthluck[0]['animal_english_element']. ",".$earthluck[0]['animal'];
                
                //For Growth Phase
                 $currentannualLuckpillar=$this->growth_phases_get($strem[0]['chinese_element'],$earthluck[0]['animal']);	
                 $growthLP[]=$currentannualLuckpillar[0]['Key_2'];

                //hiddenstem in Luckpillar

                $hiddenLC = $this->hidden_stems_get($earthluck[0]['animal_chinese_element']);

                $hiddenstemdata = $hiddenLC[0]['hidden_stems'];
                $hiddenstemicon = $hiddenLC[0]['icon'];
                $hsdlc = explode(',', $hiddenstemdata);
                $hsdilc = explode(',', $hiddenstemicon);
                $countlc = count($hsdlc);
                $hsdilcdata = "";
                if ($countlc == 3) {
                    $hsdlcdata = $hsdlc[0] . "  " . $hsdlc[1] . "  " . $hsdlc[2];
                    $enelname19=$this->heavenly_stem_by_name_get($hsdlc[0]);
                    $enelname20=$this->heavenly_stem_by_name_get($hsdlc[1]);
                    $enelname21=$this->heavenly_stem_by_name_get($hsdlc[2]);
                    $hsdlcedata= strtr($enelname19[0]['english_element']." ".$enelname20[0]['english_element']." ".$enelname21[0]['english_element'],$arrayrelpace);
                    $hsdilcdata .= "<img src='" . get_assets_path() . $hsdilc[0] . "' style='width: 30px;color:pink'> <img src='" . get_assets_path() . $hsdilc[1] . "' style='width: 30px;color:pink'><img src='" . get_assets_path() . $hsdilc[2] . "' style='width:30px;'>";

                        //for 10 gods 
                        $finacila_density16= $this->financial_density_get($strem[0]['chinese_element'],$enelname19[0]['english_element']);
                        $finacila_density17= $this->financial_density_get($strem[0]['chinese_element'],$enelname20[0]['english_element']);
                        $finacila_density18= $this->financial_density_get($strem[0]['chinese_element'],$enelname21[0]['english_element']);
                        $finacialdensityLuckPillarE1=explode(',',$finacila_density16[0][$strem[0]['chinese_element']]);
                        $finacialdensityLuckPillarE2=explode(',',$finacila_density17[0][$strem[0]['chinese_element']]);
                        $finacialdensityLuckPillarE3=explode(',',$finacila_density18[0][$strem[0]['chinese_element']]);
                        $finacialdensityLuckPillar=  $finacialdensityLuckPillarE1[1]." ".$finacialdensityLuckPillarE2[1]." ". $finacialdensityLuckPillarE3[1];

                } else if ($countlc == 2) {
                    $hsdlcdata = $hsdlc[0] . " " . $hsdlc[1];
                    $enelname19=$this->heavenly_stem_by_name_get($hsdlc[0]);
                    $enelname20=$this->heavenly_stem_by_name_get($hsdlc[1]);
                    $hsdlcedata= strtr($enelname19[0]['english_element']." ".$enelname20[0]['english_element'],$arrayrelpace);
                    $hsdilcdata .= "<img src='" . get_assets_path() . $hsdilc[0] . "' style='width: 30px;color:pink'> <img src='" . get_assets_path() . $hsdilc[1] . "' style='width: 30px;color:pink'>";

                    //for 10 gods 
                    $finacila_density16= $this->financial_density_get($strem[0]['chinese_element'],$enelname19[0]['english_element']);
                    $finacila_density17= $this->financial_density_get($strem[0]['chinese_element'],$enelname20[0]['english_element']);
                    $finacialdensityLuckPillarE1=explode(',',$finacila_density16[0][$strem[0]['chinese_element']]);
                    $finacialdensityLuckPillarE2=explode(',',$finacila_density17[0][$strem[0]['chinese_element']]);
                    $finacialdensityLuckPillar=  $finacialdensityLuckPillarE1[1]." ".$finacialdensityLuckPillarE2[1];


                } else {
                    $hsdlcdata = $hsdlc[0];
                    $enelname19=$this->heavenly_stem_by_name_get($hsdlc[0]);
                    $hsdlcedata= strtr($enelname19[0]['english_element'],$arrayrelpace);
                    $hsdilcdata .= "<img src='" . get_assets_path() . $hsdilc[0] . "' style='width: 30px;color:pink'>";

                    //for 10 gods 
                    $finacila_density16= $this->financial_density_get($strem[0]['chinese_element'],$enelname19[0]['english_element']);
                    $finacialdensityLuckPillarE1=explode(',',$finacila_density16[0][$strem[0]['chinese_element']]);
                    $finacialdensityLuckPillar=  $finacialdensityLuckPillarE1[1];

                }

                $luckpillarhiddenstem[] = $hsdlcdata . "," . $hsdilcdata.",".$hsdlcedata.",".$finacialdensityLuckPillar;
            }
        } else {


            $month = strtolower(date('M', strtotime($birttdate)));
            $where5 = array('year' => $year);
            $monthstratdate = $this->query->get_details($month, 'chinese_month_start', $where5);


            if ($birttdate < $monthstratdate[0][$month]) {
                $month = strtolower(date('M', strtotime($birttdate . " -1 months")));
                $where5 = array('year' => $year);
                $monthstratdate = $this->query->get_details($month, 'chinese_month_start', $where5);
            } else {
                $month = strtolower(date('M', strtotime($birttdate)));
            }
            $date11 = date_create($birttdate);
            $date22 = date_create($monthstratdate[0][$month]);

            $diff = date_diff($date22, $date11);
            $backward = $diff->format("%R%a") / 3;
            $stem_id = $stremmonth[0]['id'];
            $earth_id = $queryearthmo[0]['id'];



            for ($i = 1; $i <= 10; $i++) {
                $forarray[] = round($backward);
                $backward = $backward + 10;
            }

            for ($i = 1; $i <= 10; $i++) {

                $stem_id--;
                if ($stem_id == 0) {
                    $stem_id = 10;
                }
                $stem_id_array[] = $stem_id;
            }

            $arryrev = $stem_id_array;
            $arrlengthss = count($arryrev);
            for ($y = 0; $y < $arrlengthss; $y++) {


                $stemluck = $this->heavenly_stem_by_id_get($arryrev[$y]);
                $luckpillarstem[] = $stemluck[0]['chinese_icon'] . "," . $stemluck[0]['chinese_element'] . "," . $stemluck[0]['english_element'];
            }

            for ($i = 1; $i <= 10; $i++) {
                $earth_id--;
                if ($earth_id == 0) {
                    $earth_id = 12;
                }
                $earth_id_array[] = $earth_id;
            }

            $arryrevearth = $earth_id_array;
            $arrlengthsse = count($arryrevearth);
            for ($k = 0; $k < $arrlengthsse; $k++) {


                $earthluck = $this->earthly_branches_by_id_get($arryrevearth[$k]);
                $luckpillarearth[] = $earthluck[0]['animal_chinese_icon'] . "," . $earthluck[0]['animal_chinese_element'] . "," . $earthluck[0]['animal_english_element']. "," . $earthluck[0]['animal'];
                
                //For Growth Phase
                 $currentannualLuckpillar=$this->growth_phases_get($strem[0]['chinese_element'],$earthluck[0]['animal']);	
                 $growthLP[]=$currentannualLuckpillar[0]['Key_2'];

                //hiddenstem in Luckpillar

                $hiddenLC = $this->hidden_stems_get($earthluck[0]['animal_chinese_element']);

                $hiddenstemdata = $hiddenLC[0]['hidden_stems'];
                $hiddenstemicon = $hiddenLC[0]['icon'];
                $hsdlc = explode(',', $hiddenstemdata);
                $hsdilc = explode(',', $hiddenstemicon);
                $countlc = count($hsdlc);
                $hsdilcdata = "";
                if ($countlc == 3) {
                    $hsdlcdata = $hsdlc[0] . "  " . $hsdlc[1] . "  " . $hsdlc[2];
                    $enelname19=$this->heavenly_stem_by_name_get($hsdlc[0]);
                    $enelname20=$this->heavenly_stem_by_name_get($hsdlc[1]);
                    $enelname21=$this->heavenly_stem_by_name_get($hsdlc[2]);
                    $hsdlcedata= strtr($enelname19[0]['english_element']." ".$enelname20[0]['english_element']." ".$enelname21[0]['english_element'],$arrayrelpace);
                    $hsdilcdata .= "<img src='" . get_assets_path() . $hsdilc[0] . "' style='width: 30px;color:pink'> <img src='" . get_assets_path() . $hsdilc[1] . "' style='width: 30px;color:pink'><img src='" . get_assets_path() . $hsdilc[2] . "' style='width:30px;'>";

                        //for 10 gods 
                        $finacila_density16= $this->financial_density_get($strem[0]['chinese_element'],$enelname19[0]['english_element']);
                        $finacila_density17= $this->financial_density_get($strem[0]['chinese_element'],$enelname20[0]['english_element']);
                        $finacila_density18= $this->financial_density_get($strem[0]['chinese_element'],$enelname21[0]['english_element']);
                        $finacialdensityLuckPillarE1=explode(',',$finacila_density16[0][$strem[0]['chinese_element']]);
                        $finacialdensityLuckPillarE2=explode(',',$finacila_density17[0][$strem[0]['chinese_element']]);
                        $finacialdensityLuckPillarE3=explode(',',$finacila_density18[0][$strem[0]['chinese_element']]);
                        $finacialdensityLuckPillar=  $finacialdensityLuckPillarE1[1]." ".$finacialdensityLuckPillarE2[1]." ". $finacialdensityLuckPillarE3[1];

                } else if ($countlc == 2) {
                    $hsdlcdata = $hsdlc[0] . " " . $hsdlc[1];
                    $enelname19=$this->heavenly_stem_by_name_get($hsdlc[0]);
                    $enelname20=$this->heavenly_stem_by_name_get($hsdlc[1]);
                    $hsdlcedata= strtr($enelname19[0]['english_element']." ".$enelname20[0]['english_element'],$arrayrelpace);
                    $hsdilcdata .= "<img src='" . get_assets_path() . $hsdilc[0] . "' style='width: 30px;color:pink'> <img src='" . get_assets_path() . $hsdilc[1] . "' style='width: 30px;color:pink'>";

                    //for 10 gods 
                    $finacila_density16= $this->financial_density_get($strem[0]['chinese_element'],$enelname19[0]['english_element']);
                    $finacila_density17= $this->financial_density_get($strem[0]['chinese_element'],$enelname20[0]['english_element']);
                    $finacialdensityLuckPillarE1=explode(',',$finacila_density16[0][$strem[0]['chinese_element']]);
                    $finacialdensityLuckPillarE2=explode(',',$finacila_density17[0][$strem[0]['chinese_element']]);
                    $finacialdensityLuckPillar=  $finacialdensityLuckPillarE1[1]." ".$finacialdensityLuckPillarE2[1];


                } else {
                    $hsdlcdata = $hsdlc[0];
                    $enelname19=$this->heavenly_stem_by_name_get($hsdlc[0]);
                    $hsdlcedata= strtr($enelname19[0]['english_element'],$arrayrelpace);
                    $hsdilcdata .= "<img src='" . get_assets_path() . $hsdilc[0] . "' style='width: 30px;color:pink'>";

                    //for 10 gods 
                    $finacila_density16= $this->financial_density_get($strem[0]['chinese_element'],$enelname19[0]['english_element']);
                    $finacialdensityLuckPillarE1=explode(',',$finacila_density16[0][$strem[0]['chinese_element']]);
                    $finacialdensityLuckPillar=  $finacialdensityLuckPillarE1[1];

                }

                $luckpillarhiddenstem[] = $hsdlcdata . "," . $hsdilcdata.",".$hsdlcedata.",".$finacialdensityLuckPillar;
            }
        }

        //Month Pillar Logic
        for ($m = 1; $m <= 12; $m++) {
            $startmonth = date('M', mktime(0, 0, 0, $m, 1));
            $startmonthdate = $this->start_month_get(strtolower($startmonth));
            $mothstartdate[] = date('M j', strtotime($startmonthdate[0][(strtolower($startmonth))]));

           // log_message("error", $startmonthdate[0][(strtolower($startmonth))]);
            $datemonth = $startmonthdate[0][(strtolower($startmonth))];
            $cur_year = date('Y', strtotime($startmonthdate[0][(strtolower($startmonth))]));
            $cur_month_num = date('m', strtotime($startmonthdate[0][(strtolower($startmonth))]));
            $cur_month = date('M', strtotime($startmonthdate[0][(strtolower($startmonth))]));
            //log_message("error", $cur_month_num);
            $curstemmonth = ((($cur_year - $initial_year) * 12) + $cur_month_num) % 10 + $initial_stem_month;

            if ($curstemmonth > 10) {
                $curstemmonth = $curstemmonth % 10;
            }

            $where4 = array('year' => $cur_year);
            $monthbirttdate1 = $this->query->get_details(strtolower($cur_month), 'chinese_month_start', $where4);

            if ($datemonth < $monthbirttdate1[0][strtolower($cur_month)]) {

                $curstemmonth = $curstemmonth - 1;
            }

            $curstremmonth = $this->heavenly_stem_by_id_get($curstemmonth);
            $currentyearstem[] = $curstremmonth[0]['chinese_element'] . "," . $curstremmonth[0]['english_element'] . "," . $curstremmonth[0]['chinese_icon'];
           

            $curearthmmonth = ((($cur_year - $initial_year) * 12) + $cur_month_num) % 12 + $initial_earth_month;
            if ($curearthmmonth > 12) {
                $curearthmmonth = $curearthmmonth % 12;
            }

            if ($datemonth < $monthbirttdate1[0][strtolower($cur_month)]) {

                $curearthmmonth = $curearthmmonth - 1;
            }

            $curqueryearthmo1 = $this->earthly_branches_by_id_get($curearthmmonth);
            $currentyearearth[] = $curqueryearthmo1[0]['animal_chinese_element'] . "," . $curqueryearthmo1[0]['animal_english_element'] . "," . $curqueryearthmo1[0]['animal_chinese_icon'].",".$curqueryearthmo1[0]['animal'];

           //For Growth Phase
            $currentannualGP=$this->growth_phases_get($strem[0]['chinese_element'],$curqueryearthmo1[0]['animal']);	
	        $growthP[]=$currentannualGP[0]['Key_2'];
              
             
            //hiddenstem in MonthPillar
            $hiddenmonthMC = $this->hidden_stems_get($curqueryearthmo1[0]['animal_chinese_element']);
            $hiddenstemdataMC = $hiddenmonthMC[0]['hidden_stems'];
            $hiddenstemiconMc = $hiddenmonthMC[0]['icon'];
            $hsdmc = explode(',', $hiddenstemdataMC);
            $hsdimc = explode(',', $hiddenstemiconMc);
            $countmc = count($hsdmc);
            $hsdimcdata = "";
            if ($countmc == 3) {
                $hsdmcdata = $hsdmc[0] . "  " . $hsdmc[1] . "  " . $hsdmc[2];
                $enelname13=$this->heavenly_stem_by_name_get($hsdmc[0]);
                $enelname14=$this->heavenly_stem_by_name_get($hsdmc[1]);
                $enelname15=$this->heavenly_stem_by_name_get($hsdmc[2]);
                $hstmistring= strtr($enelname13[0]['english_element']." ".$enelname14[0]['english_element']." ".$enelname15[0]['english_element'],$arrayrelpace);
                $hsmie= $enelname13[0]['english_element'].",".$enelname14[0]['english_element'].",".$enelname15[0]['english_element'];
                $hsdimcdata .= "<img src='" . get_assets_path() . $hsdimc[0] . "' style='width: 30px;color:pink'> <img src='" . get_assets_path() . $hsdimc[1] . "' style='width: 30px;color:pink'><img src='" . get_assets_path() . $hsdimc[2] . "' style='width:30px;'>";

                   //for 10 gods 
                   $finacila_density19= $this->financial_density_get($strem[0]['chinese_element'],$enelname13[0]['english_element']);
                   $finacila_density20= $this->financial_density_get($strem[0]['chinese_element'],$enelname14[0]['english_element']);
                   $finacila_density21= $this->financial_density_get($strem[0]['chinese_element'],$enelname15[0]['english_element']);
                   $finacialdensityMontpillarE1=explode(',',$finacila_density19[0][$strem[0]['chinese_element']]);
                   $finacialdensityMontpillarE2=explode(',',$finacila_density20[0][$strem[0]['chinese_element']]);
                   $finacialdensityMontpillarE3=explode(',',$finacila_density21[0][$strem[0]['chinese_element']]);
                   $finacialdensityMonthPillar= $finacialdensityMontpillarE1[1]." ".$finacialdensityMontpillarE2[1]." ". $finacialdensityMontpillarE3[1];


            } else if ($countmc == 2) {
                $hsdmcdata = $hsdmc[0] . " " . $hsdmc[1];
                $enelname13=$this->heavenly_stem_by_name_get($hsdmc[0]);
                $enelname14=$this->heavenly_stem_by_name_get($hsdmc[1]);
                $hstmistring=  strtr($enelname13[0]['english_element']." ".$enelname14[0]['english_element'],$arrayrelpace);
                $hsmie= $enelname13[0]['english_element'].",".$enelname14[0]['english_element'];
                $hsdimcdata .= "<img src='" . get_assets_path() . $hsdimc[0] . "' style='width: 30px;color:pink'> <img src='" . get_assets_path() . $hsdimc[1] . "' style='width: 30px;color:pink'>";

                 //for 10 gods 
                 $finacila_density19= $this->financial_density_get($strem[0]['chinese_element'],$enelname13[0]['english_element']);
                 $finacila_density20= $this->financial_density_get($strem[0]['chinese_element'],$enelname14[0]['english_element']);
                 $finacialdensityMontpillarE1=explode(',',$finacila_density19[0][$strem[0]['chinese_element']]);
                 $finacialdensityMontpillarE2=explode(',',$finacila_density20[0][$strem[0]['chinese_element']]);
                 $finacialdensityMonthPillar= $finacialdensityMontpillarE1[1]." ".$finacialdensityMontpillarE2[1];

            } else {
                
                $hsdmcdata = $hsdmc[0];
                $enelname13=$this->heavenly_stem_by_name_get($hsdmc[0]);
                $hstmistring=  strtr($enelname13[0]['english_element'],$arrayrelpace);
                $hsmie= $enelname13[0]['english_element'];
                $hsdimcdata .= "<img src='" . get_assets_path() . $hsdimc[0] . "' style='width: 30px;color:pink'>";
                //for 10 gods 
                $finacila_density19= $this->financial_density_get($strem[0]['chinese_element'],$enelname13[0]['english_element']); 
                $finacialdensityMontpillarE1=explode(',',$finacila_density19[0][$strem[0]['chinese_element']]);
                $finacialdensityMonthPillar= $finacialdensityMontpillarE1[1];
            }
                
            $monthpillarhiddenstem[] = $hsdmcdata .",". $hsdimcdata.",".$hstmistring.",".$finacialdensityMonthPillar;
            
          //For Annual element Count
             $curstemcountarray[]=$curstremmonth[0]['english_element'];
             $curearthmcountarray[]=$curqueryearthmo1[0]['animal_english_element'];
             $curhiddenstemcountarray[]=$hsmie;
             $hidstemNA[]=$hsdmcdata;
             $stemdstemNA[]= $curstremmonth[0]['chinese_element'];
            
         }
          $curhiddenstemcount= implode(",",$curhiddenstemcountarray);  
          $hiddenstemarray= explode(",",$curhiddenstemcount); 
        
           $monthlycount=array_merge($curstemcountarray,$curearthmcountarray,$hiddenstemarray);
           //with element count
           $countannualelement=array_count_values($monthlycount);
            //for single element count
            $arraystringA=implode(",",$monthlycount);
            $singlestrA=str_replace("Yang","",$arraystringA);
            $singlestr1A=str_replace("Yin","",$singlestrA);  
            $singleelemetA=explode(",",$singlestr1A);
            $singlecountelementA=array_count_values($singleelemetA); 
       
       //Code Start For profile strenght chart Natal   
        $stemelementPS = $this->query->get_details('*','heavenly_stems');
        
        //Code Start For profile strenght chart Annual
        $hstemimp= implode(" ",$hidstemNA);
        $hstemAN= array_filter(explode(" ", $hstemimp));
        $stemelementprofileAN= array_merge($hstemAN,$stemdstemNA);
        $meragearrayAN=array_filter($stemelementprofileAN);
        $countofchinieselementAN= array_count_values($meragearrayAN);
       //For Finacial density
        $finacila_density= $this->profile_stength_financial_density_get($strem[0]['chinese_element']);
        foreach($finacila_density as $fin)
        {
            $finden[]=$fin[$strem[0]['chinese_element']];
        }

        //kua no color and element fetch

        $color_element=$this->color_elements_get($sting);


       
   //Response Send Start Here
        if (is_array($natalchart) && !empty($natalchart)) {
            $this->response(['status' => 'success', 'message' => '', 'data' => array('natalchart' => $natalchart, 'star' => $sting, 'favorable_directionval'=>$favorable_direction_detail, 'unfavorable_directionval'=>$unfavorable_direction_detail, 'daymaster' => $daymaster, 'topcountLC' => $forarray, 'stemLC' => $luckpillarstem, 'earthLC' => $luckpillarearth, 'hiddenstemLC' => $luckpillarhiddenstem, 'startdatemonth' => $mothstartdate, 'currentyearstem' => $currentyearstem, 'currentyearerath' => $currentyearearth, 'monthpillarhiddenstem' => $monthpillarhiddenstem,'annualelementcout'=>$singlecountelementA,'stemelementPS'=>$stemelementPS,'finacila_density'=>$finden,'meragearrayAN'=>$meragearrayAN,'countofchinieselementAN'=>$countofchinieselementAN,'currentannualGP'=>$growthP,'color_element'=>$color_element,'growthPLP'=>$growthLP)], REST_Controller::HTTP_OK);
        }
    }

//***********************Common Function Start*****************************************************************************


    public function heavenly_stem_by_id_get($id) {
        $where = array('id' => $id);
        $heavenly_stem_data = $this->query->get_details('*', 'heavenly_stems', $where);
        if (is_array($heavenly_stem_data)) {
            return $heavenly_stem_data;
        }
    }

    public function earthly_branches_by_id_get($id) {
        $where = array('id' => $id);
        $earthly_branches_data = $this->query->get_details('*','earthly_branches', $where);
        if (is_array($earthly_branches_data)) {
            return $earthly_branches_data;
        }
    }

    public function heavenly_stem_by_name_get($chname) {
        $where = array('chinese_element' => $chname);
        $heavenly_stem_data = $this->query->get_details('*', 'heavenly_stems', $where);
        if (is_array($heavenly_stem_data)) {
            return $heavenly_stem_data;
        }
    }

    public function earthly_branches_by_name_get($chname) {
        $where = array('animal_chinese_element' => $chname);
        $earthly_branches_data = $this->query->get_details('*', 'earthly_branches', $where);
        if (is_array($earthly_branches_data)) {
            return $earthly_branches_data;
        }
    }

    public function hidden_stems_get($earthly_branch) {
        $where = array('earthly_branch' => $earthly_branch);
        $earthly_branches_data = $this->query->get_details('*', 'hidden_stems', $where);
        if (is_array($earthly_branches_data)) {
            return $earthly_branches_data;
        }
    }

    public function start_month_get($month) {
        $currentyear = date('Y');
        $whereyear = array('year' => $currentyear);
        $startmonth = $this->query->get_details($month, 'chinese_month_start', $whereyear);
        if (is_array($startmonth)) {
            return $startmonth;
        }
    }
 
     public function profile_stength_financial_density_get($dayelement) {
        $finacial_density = $this->query->get_details($dayelement, 'financial_density');
        //log_message("error",$this->db->last_query());
        if (is_array($finacial_density)) {
            return $finacial_density;
        }
    }

    public function financial_density_get($dayelement,$element) {
        $where=array('elements'=>$element);
        $finacial_density = $this->query->get_details($dayelement, 'financial_density',$where);
        if (is_array($finacial_density)) {
            return $finacial_density;
        }
    }
    
     public function favorable_direction_get($kau_no) {
        $where = array('kua_no' => $kau_no);
        $favorable_direction = $this->query->get_details("*",'favorable_direction',$where); 
        if (is_array($favorable_direction)) {
            return $favorable_direction;
        }
    }
     public function unfavorable_direction_get($kau_no) {
        $where = array('kua_no' => $kau_no);
        $unfavorable_direction = $this->query->get_details("*",'unfavorable_direction',$where); 
        if (is_array($unfavorable_direction)) {
            return $unfavorable_direction;
        }
    }
    
     public function growth_phases_get($column,$animal) {
        $where = array($column => $animal);
        $growth_phases = $this->query->get_details('*','growth_phase',$where); 
        if (is_array($growth_phases)) {
            return $growth_phases;
        }
    }

    public function color_elements_get($kau_no) {
        $where = array('kua_no' => $kau_no);
        $color_element_kua = $this->query->get_details('*','color_element_kua',$where); 
        if (is_array($color_element_kua)) {
            return  $color_element_kua;
        }
    }


    public function life_star_get($year, $gender) {

        $additionFlag = 0; //flag to set addition of the variable
        $OutPut = 0;  //to release the values

        //year wise change the value
        if ($year < 2000) {
            if ($gender == 'Female') {
                $additionVar = +5;
            } else if ($gender == 'Male') {
                $additionVar = -10;
            }
        } else if ($year >= 2000) {
            if ($gender == 'Female') {
                $additionVar = +6;
            } else if ($gender == 'Male') {
                $additionVar = -9;
            }
        }

        //add two last number togather
        $lastTwoCharacter = substr($year, -2);
        $OutPut = array_sum(str_split($lastTwoCharacter));
        
        
        // if check on first addition value length is 1, then add as per above code
        if (strlen($OutPut) == 1) {
            $additionFlag = 1;
            $OutPut = $OutPut + $additionVar;
        }

        //Please add twp value togather till it will become single value.
        while (strlen($OutPut) > 1) {
            $OutPut = array_sum(str_split($OutPut));

            if (strlen($OutPut) == 1 && $additionFlag == 0) {
                $additionFlag = 1;
                $additionVar;

                $OutPut = $OutPut + $additionVar;
            }
        }
        if($OutPut==5 && $gender=='Female')
        {
            $OutPut=8;  
        }
        elseif($OutPut==5 && $gender=='Male')
        {
            $OutPut=2;  
        }
        
        return $OutPut;
     
    }

    
}
