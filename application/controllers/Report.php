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

                        if($this->form_validation->run() == FALSE) {
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



                    if($this->input->post('reportid')==md5(2))
                    {
                        $this->form_validation->set_rules('first_name', 'First Name', 'required');
                        $this->form_validation->set_rules('last_name', 'Last Name', 'required');
                        $this->form_validation->set_rules('birttdate', 'Date Of Birth', 'required');
                      // $this->form_validation->set_rules('birthtime', 'Birth Time', 'required');
                        $this->form_validation->set_rules('gender', 'Gender', 'required');

                        if($this->form_validation->run() == FALSE) {
                        $this->template->load('template','report_personal_detail');
                        } else {

                            $params['FirstName'] = $this->input->post('first_name');
                            $params['LastName'] = $this->input->post('last_name');
                            $params['birttdate'] = $this->input->post('birttdate');
                            $params['birthtime'] = $this->input->post('birthtime');
                            $params['gender'] = $this->input->post('gender');
                           // $params['DNbirthtime'] = $this->input->post('DNbirthtime');
                            $api = base_url() . "api/report/flystar_report";
                            $json_data = json_decode($this->restclient->post($api, $params), true);
                            if ($json_data['status'] == 'success') {
                                $data['data'] = $json_data['data'];
                                $this->template->load('template','flystar',$data);
                            }
                        }
                       
                    }
                   
                }

           }
       }
    }

public function select_period()
{
    $year=$this->input->post('Year');

        if($year >= 1864 && $year < 1884)
        {
            echo ' <option value="1">Period 1 (Feb 1864 - Feb 1884)</option>';
        }
        else if($year >= 1884 && $year < 1904)
        {
            echo '<option value="2">Period 2 (Feb 1884 - Feb 1904)</option>';
        }
        else if($year >= 1904 && $year < 1924)
        {
            echo '<option value="3">Period 3 (Feb 1904 - Feb 1924)</option>';
        }
        else if($year >= 1924 && $year < 1944)
        {
            echo '<option value="4">Period 4 (Feb 1924 - Feb 1944)</option>';
        }
        else if($year >= 1944 && $year < 1964)
        {
            echo '<option value="5">Period 5 (Feb 1944 - Feb 1964)</option>';
        }
        else if($year >= 1964 && $year < 1984)
        {
            echo '<option value="6">Period 6 (Feb 1964 - Feb 1984)</option>';
        }
        else if($year >= 1984 && $year < 2004)
        {
            echo '<option value="7">Period 7 (Feb 1984 - Feb 2004)</option>';
        }
        else if($year >= 2004 && $year < 2024)
        {
            echo '<option  value="8">Period 8 (Feb 2004 - Feb 2024)</option>';
        }
        else if($year >= 2024 && $year < 2044)
        {
            echo '<option value="9">Period 9 (Feb 2024 - Feb 2044)</option>';
        }
        else
        {
        echo  '<option value="1">Period 1 (Feb 1864 - Feb 1884)</option>
        <option value="2">Period 2 (Feb 1884 - Feb 1904)</option>
        <option value="3">Period 3 (Feb 1904 - Feb 1924)</option>
        <option value="4">Period 4 (Feb 1924 - Feb 1944)</option>
        <option value="5">Period 5 (Feb 1944 - Feb 1964)</option>
        <option value="6">Period 6 (Feb 1964 - Feb 1984)</option>
        <option value="7">Period 7 (Feb 1984 - Feb 2004)</option>
        <option  value="8">Period 8 (Feb 2004 - Feb 2024)</option>
        <option value="9">Period 9 (Feb 2024 - Feb 2044)</option>';
        }


}

public function show_flying_chart()
{

    $this->form_validation->set_rules('Year', 'Year', 'required');
    $this->form_validation->set_rules('Period', 'Period', 'required');
    $this->form_validation->set_rules('facing', 'facing', 'required');
    if($this->form_validation->run() == FALSE) {
    $this->template->load('template','flystar');
    } else {

        $params['Year'] = $this->input->post('Year');
        $params['Period'] = $this->input->post('Period');
        $params['facing'] = $this->input->post('facing');
      
        $api = base_url() . "api/report/show_flying_chart";
        $json_data = json_decode($this->restclient->post($api, $params), true);
        if ($json_data['status'] == 'success') {
            $data['data'] = $json_data['data'];
            $this->load->view('flyingchart',$data);
        }
    }

    
}


}