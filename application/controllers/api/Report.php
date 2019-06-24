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

class Report extends REST_Controller {

    function __construct() {
        parent::__construct();
    }

    public function personal_direction_report_post() {
        $FirstName = $this->input->post('FirstName');
        $LastName = $this->input->post('LastName');
        $name= $FirstName ." ". $LastName;
        $birttdate = date('Y-m-d',strtotime($this->input->post('birttdate')));
        $birthtime = $this->input->post('birthtime');
        $gender = $this->input->post('gender');
        $year=date('Y',strtotime($this->input->post('birttdate')));
        $kau_no = $this->life_star_get($year, $gender);

          //Direction Coding 
          $favorable_direction_detail=$this->favorable_direction_get($kau_no);
          $unfavorable_direction_detail=$this->unfavorable_direction_get($kau_no);
         
           
            

          if(is_array($favorable_direction_detail) && is_array($unfavorable_direction_detail)){

          $this->response(['status' => 'success','message' => '', 'data' => array('favorable_directionval'=>$favorable_direction_detail, 'unfavorable_directionval'=>$unfavorable_direction_detail,'name'=>$name,'gender'=>$gender,'DOB'=>$birttdate,'birthtime'=>$birthtime)], REST_Controller::HTTP_OK);
          }
     
    }   

//common function
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
            if($OutPut==0)
                {
                    $OutPut=abs($additionVar);
                }
        }
        //Please add twp value togather till it will become single value.
        while (strlen($OutPut) > 1) {
            $OutPut = array_sum(str_split($OutPut));

            if (strlen($OutPut) == 1 && $additionFlag == 0) {
                $additionFlag = 1;
                $additionVar;

                $OutPut = $OutPut + $additionVar;
                if($OutPut==0)
                {
                    $OutPut=abs($additionVar);
                }

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




}
    