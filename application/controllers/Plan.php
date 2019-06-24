<?php

(defined('BASEPATH')) OR exit('No direct script access allowed');

/**
 * Description of site
 *
 * @author Harshal Patil
 * This is controller file for Login to dashboard
 * 
 */
class Plan extends CI_Controller {

    function __construct() {
        parent::__construct();

        // Load Rest Client Library
        $this->load->library("restclient");
        $this->load->library('form_validation');
        $this->load->helper("check_token_helper");
       // $this->load->library('encrypt');
    }

    public function index() {
        $user_id=$this->session->userdata('UserId');
        $IsLogin=$this->session->userdata('IsLogin');
        $Istoken=$this->session->userdata('Token');     
	   if($IsLogin !=true && empty($user_id))
       {
          redirect('user');
       }
        else{
            $checktoken=check_token($Istoken,$user_id);
             if(empty($checktoken))
           {
            $this->session->set_flashdata('success',"Not a valid Session");
            redirect('user/logout');
           } else{
                if((!empty($this->input->get('report_id'))))
                {
                    $this->template->load('template','report_personal_detail');   
                
                } 
                else{
                    $this->template->load('template','myplan');
                }

           }
       }
    }




}