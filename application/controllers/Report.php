<?php

(defined('BASEPATH')) OR exit('No direct script access allowed');

/**
 * Description of site
 *
 * @author Harshal Patil
 * This is controller file for Login to dashboard
 * 
 */
class Report extends CI_Controller {

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
                if(!empty($_POST))
                {
                    if($this->input->post('reportid')==md5(1))
                    {
                        $this->form_validation->set_rules('first_name', 'First Name', 'required');
                        $this->form_validation->set_rules('last_name', 'Last Name', 'required');
                        $this->form_validation->set_rules('birttdate', 'Date Of Birth', 'required');
                    // $this->form_validation->set_rules('birthtime', 'Birth Time', 'required');
                        $this->form_validation->set_rules('gender', 'Gender', 'required');

                        if ($this->form_validation->run() == FALSE) {
                        $this->template->load('template','report_personal_detail');
                        } else {

                            $params['FirstName'] = $this->input->post('first_name');
                            $params['LastName'] = $this->input->post('last_name');
                            $params['birttdate'] = $this->input->post('birttdate');
                            $params['birthtime'] = $this->input->post('birthtime');
                            $params['gender'] = $this->input->post('gender');
                           // $params['DNbirthtime'] = $this->input->post('DNbirthtime');
                            $api = base_url() . "api/report/personal_direction_report";
                            $json_data = json_decode($this->restclient->post($api, $params), true);
                            if ($json_data['status'] == 'success') {
                                $data['data'] = $json_data['data'];
                                $this->template->load('template','personal_direction',$data);
                            }
                        }

                       
                    }







                   
                }

           }
       }
    }




}