<?php

(defined('BASEPATH')) OR exit('No direct script access allowed');

/**
 * Description of site
 *
 * @author Harshal Patil
 * This is controller file for Login to dashboard
 * 
 */
class Profile extends CI_Controller {

    function __construct() {
        parent::__construct();

        // Load Rest Client Library
        $this->load->library("restclient");
        $this->load->library('form_validation');
        $this->load->helper("check_token_helper");
    }

    public function index() {
        $user_id=$this->session->userdata('UserId');
        $IsLogin=$this->session->userdata('IsLogin');
        $Istoken=$this->session->userdata('Token');     
	   if($IsLogin !=true && empty($user_id))
       {
           $this->template->load('template','login');
       }
        else{
            $checktoken=check_token($Istoken,$user_id);
            if(empty($checktoken))
           {
            $this->session->set_flashdata('error',"Not a valid Session");
            redirect('user/logout');
           } else{
               $data['userdetail']=$this->UserDetail($user_id);
                $this->template->load('template','profile',$data);
           }
       }
    }

    public function UserDetail($user_id)
	{
        $IsLogin=$this->session->userdata('IsLogin');
        $Istoken=$this->session->userdata('Token');     
	   if($IsLogin !=true && empty($user_id))
       {
          $this->template->load('template','login');
       }
        else{
            $checktoken=check_token($Istoken,$user_id);
            if(empty($checktoken))
           {
            $this->session->set_flashdata('error',"Not a valid Session");
            redirect('user/logout');
           } else{
                $params['user_id'] =   $user_id;
                $api =  base_url() . "api/profile/UserDetail";				
                $json_data = json_decode($this->restclient->post($api,$params),true);
                if($json_data['status'] == 'success')
                {
                    return $json_data['data'];
                }
           }
       }
		
	
    }
    
    public function edit_profile()
    {
        $user_id=$this->session->userdata('UserId');
        $IsLogin=$this->session->userdata('IsLogin');
        $Istoken=$this->session->userdata('Token');     
	   if($IsLogin !=true && empty($user_id))
       {
          $this->template->load('template','login');
       }
        else{
            $checktoken=check_token($Istoken,$user_id);
            if(empty($checktoken))
           {
            $this->session->set_flashdata('error',"Not a valid Session");
            redirect('user/logout');
           } else{
            $data['userdetail']=$this->UserDetail($user_id);
             //validation      
             $this->form_validation->set_rules('first_name', 'First Name', 'required');
             $this->form_validation->set_rules('last_name', 'Last Name', 'required');
             $this->form_validation->set_rules('mobile', 'Phone Number', 'required|numeric|max_length[15]');
             $this->form_validation->set_rules('email', 'Email', 'trim|required|valid_email');
             $this->form_validation->set_rules('DOB', 'Date Of Birth', 'required');
             $this->form_validation->set_rules('birth_time', 'Birth Time', 'required');
             $this->form_validation->set_rules('gender', 'Gender', 'required');
             if ($this->form_validation->run() == FALSE) {

                   $this->template->load('template', 'profile', $data);
             } else {

                $params['user_id'] =   $user_id;
                $params['FirstName'] = $this->input->post('first_name');
                $params['LastName'] = $this->input->post('last_name');
                $params['Mobile'] = $this->input->post('mobile');
                $params['Gender'] = $this->input->post('gender');
                $params['BirthDate'] = $this->input->post('DOB');
                $params['BirthTime'] = $this->input->post('birth_time');
                $params['gender'] = $this->input->post('gender');
                $api =  base_url() . "api/profile/edit_profile";				
                $json_data = json_decode($this->restclient->post($api,$params),true);
                if($json_data['status'] == 'success')
                {
                    $this->session->set_flashdata('success', $json_data['message']);
                    $this->template->load('template','profile',$data);
                }
          
            }
        }
       }

    }

}