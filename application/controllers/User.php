<?php

ini_set('display_errors', 1);
(defined('BASEPATH')) OR exit('No direct script access allowed');

/**
 * Description of site
 *
 * @author Harshal Patil
 * This is controller file for Login to dashboard
 * 
 */
class User extends CI_Controller {

    function __construct() {
        parent::__construct();

        // Load Rest Client Library
        $this->load->library("restclient");
        $this->load->helper("check_token_helper");
        $this->load->library('form_validation');
        //$this->load->library('encrypt');
        $this->load->helper('string');
        $this->load->library('email');
    }

    public function index() {
        
        
        $user_id=$this->session->userdata('UserId');
        $IsLogin=$this->session->userdata('IsLogin');
        $Istoken=$this->session->userdata('Token');     
	   if($IsLogin ==true && !empty($user_id))
       {
          redirect('profile');
       }
 else {
          $this->template->load('template', 'login');
       }
    }

    public function signup() {
        if ($this->input->post()) {

            //validation      
            $this->form_validation->set_rules('first_name', 'First Name', 'required');
            $this->form_validation->set_rules('last_name', 'Last Name', 'required');
            $this->form_validation->set_rules('mobile', 'Mobile', 'required');
            $this->form_validation->set_rules('email', 'Email', 'trim|required|valid_email');
            $this->form_validation->set_rules('password', 'Password', 'required');
            $this->form_validation->set_rules('confirm_password', 'Confirm-Password', 'required');
            $this->form_validation->set_rules('confirm_password', 'Password Confirmation', 'required|matches[password]');
            $this->form_validation->set_rules('DOB', 'Date Of Birth', 'required');
            $this->form_validation->set_rules('birth_time', 'Birth Time', 'required');
            $this->form_validation->set_rules('gender', 'Gender', 'required');
            if ($this->form_validation->run() == FALSE) {
                $this->template->load('template', 'registration');
            } else {

                $params['FirstName'] = $this->input->post('first_name');
                $params['LastName'] = $this->input->post('last_name');
                $params['Email'] = $this->input->post('email');
                $params['Password'] = $this->input->post('password');
                $params['Mobile'] = $this->input->post('mobile');
                $params['Gender'] = $this->input->post('gender');
                $params['BirthDate'] = $this->input->post('DOB');
                $params['BirthTime'] = $this->input->post('birth_time');
                //$params['UserSubscriptionId'] = $subscriptionId;
                $params['gender'] = $this->input->post('gender');
                $api = base_url() . "api/user/signup";
                $json_data = json_decode($this->restclient->post($api, $params), true);
                if ($json_data['status'] == 'success') {
                    $this->session->set_flashdata('success', $json_data['message']);
                    $this->template->load('template', 'login');
                } else if ($json_data['status'] == 'error') {
                    $this->session->set_flashdata('error', $json_data['message']);
                    $this->template->load('template', 'login');
                }
            }
        } else {
            $this->template->load('template', 'registration');
        }
    }

    public function signin() {
        if ($this->input->post()) {

            //server side password
            $this->form_validation->set_rules('username', 'Username', 'required');
            $this->form_validation->set_rules('password', 'Password', 'required', array('required' => 'You must provide a %s.'));
            if ($this->form_validation->run() == FALSE) {
                $this->template->load('template', 'login');
            } else {
                $csrf_token = getToken(16);
                log_message("error", "userCi" . $csrf_token);
                $params['login_token'] = $csrf_token;
                $params['userName'] = $this->input->post('username');
                $params['password'] = $this->input->post('password');

                $api = base_url() . "api/user/signin";
                $json_data = json_decode($this->restclient->post($api, $params), true);
                if ($json_data['status'] == 'success') {
                    $this->session->set_userdata($json_data['data']);
                    $data['userdetail'] = $json_data['userdetail'];
                    //need to redirect profile page once get the design
                    redirect('profile');
                    // $this->template->load('template', 'personal_detail', $data);
                } else if ($json_data['status'] == 'error') {
                    $this->session->set_flashdata('error', $json_data['message']);
                    $this->template->load('template', 'login');
                }
            }
        } else {
            $this->template->load('template', 'login');
        }
    }

    public function checkEmail() {
        $email = $this->input->post('email');
        $this->db->select('user_id');
        $this->db->where('Email', $email);
        echo $this->db->get('users')->num_rows();
    }

    public function sendmail_forgot_password() {
        $from_email = "fengshui.sharmilamohanan@gmail.com";
        $to_email = $this->input->post('email');

        $where = array('Email' => $to_email);
        $checkuser = $this->query->get_details('*', 'users', $where);

        if (is_array($checkuser)) {
            $user_id = $checkuser[0]['user_id'];
            $firstname = $checkuser[0]['FirstName'];
            $lastname = $checkuser[0]['LastName'];
        }
        $token = random_string('alnum', 16);
        //$this->input->post('email');
        $message = '
      <html lang="en">
          <head>
              <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
              <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
              <title>Emailer Fengshui</title>
          </head>
          <body>
              <table width="400" border="0" cellspacing="0" cellpadding="0" align="center">
                  <tbody>
                      <tr>
                          <td align="center" bgcolor="#fafbfb">
                              <table width="380" border="0" align="center" cellpadding="0" cellspacing="0" style="background-color:#fff">
                                  <tbody>
                                      <tr>
                                          <td align="center" bgcolor="#fafbfb"><img src="' . get_assets_path() . 'images/spacer.png" width="1" height="10" alt="" style="display:block;font-size:0em;border:0px" class="CToWUd"></td>
                                      </tr>
                                      <tr>
                                          <td>
                                              <table width="380" align="center" bgcolor="#fff" cellpadding="0" cellspacing="0">
                                                  <tbody>
                                                      <tr>
                                                          <td align="center">
                                                              <table width="380" border="0" cellspacing="0" cellpadding="0">
                                                                  <tbody><tr>
                                                                          <td align="left">
                                                                              <td align="center" bgcolor="#fafbfb"><img src="' . get_assets_path() . 'images/spacer.png" width="1" height="10" alt="" style="display:block;font-size:0em;border:0px" class="CToWUd"></td>
                                                                              <a href="' . base_url() . '"><img src="' . get_assets_path() . 'images/logo.png" alt="Fengshui" title="Fengshui" width="380" class="CToWUd"></a>
                                                                          </td>
                                                                      </tr>
                                                                  </tbody></table>
                                                          </td>
                                                      </tr>
                                                      <tr>
                                                          <td align="center">
                                                              <img src="' . get_assets_path() . 'images/spacer.png" width="10" height="20" alt="" style="display:block;font-size:0em;border:0px" class="CToWUd">
                                                          </td>
                                                      </tr>
                                                      <tr>
                                                          <td align="center"><img src="' . get_assets_path() . 'images/spacer.png" width="10" height="8" alt="" style="display:block;font-size:0em;border:0px" class="CToWUd"></td>
                                                      </tr>
                                                      <tr>
                                                          <td align="center"><img src="' . get_assets_path() . 'images/spacer.png" width="10" height="14" alt="" style="display:block;border:0px" class="CToWUd"></td>
                                                      </tr>
                                                      <tr>
                                                          <td align="left" style="padding-left:20px;padding-right:20px;font-family:"Open Sans",sans-serif,arial;font-size:16px;font-weight:600;line-height:23px;color:#222">Greetings from sharmilamohanan.com!</td>
                                                      </tr>							
                                                      <tr>
                                                          <td align="center"><img src="</images/spacer.png" width="10" height="33" alt="" style="display:block;border:0px" class="CToWUd"></td>
                                                      </tr>
                                                      <tr>
                                                          <td align="left" style="padding-left:20px;font-family:"Open Sans",sans-serif,arial;font-size:14px;line-height:18px;color:#222">Please click below link to reset your password<br/>
                                                              <br/>
                                                             <a href="' . base_url() . 'user/change_password/' . $token . '_' . $user_id . '">Click Here</a></td>
                                                      </tr>
      
                                                     
                                                          <td align="left" style="padding-top:24px;padding-left:20px;padding-right:20px;font-family:"Open Sans",sans-serif,arial;font-size:15px;line-height:22px;color:#222">
      
                                                              <br/><br/>
                                                              Thanks & Regards,<br/>
                                                              Sharmila mohanan Team
                                                              <br/><br/>
                                                              <span style="font-family:"Open Sans",sans-serif,arial;font-size:8px;line-height:16px;color:#222"> DO NOT REPLY TO THIS MAIL. THIS IS AN AUTO GENERATED MAIL AND REPLIES TO THIS EMAIL ID ARE NOT ATTENDED.</span></td>
                                                      </tr>
                                                      <tr>
                                                          <td align="center"><img src="' . get_assets_path() . 'images/spacer.png" width="1" height="29" alt="" style="display:block;border:0px" class="CToWUd"></td>
                                                      </tr>
                                                      <tr>
                                                          <td align="center"><img src="' . get_assets_path() . 'images/spacer.png" width="380" height="10" alt="" style="display:block;border-bottom:1px solid #f3f7f8" class="CToWUd"></td>
                                                      </tr>
                                                  </tbody>
                                              </table>
                                          </td>
                                      </tr>
                                  </tbody>
                              </table>
                          </td>
                      </tr>
                  </tbody>
              </table>
          </body>
      </html>';
        //Load email library
        $this->email->set_header('Content-Type', 'text/html');
        $this->email->from($from_email, 'Fengshui');
        $this->email->to($to_email);
        $this->email->subject('Change Password');
        $this->email->message($message);
        //Send mail
        if ($this->email->send()) {
            //update token in database
            $data_array = array('token' => $token, 'modify_date' => date('Y-m-d H:i:s'));
            $result = $this->query->update('users', $data_array, array('user_id' => $user_id));
            echo 0;
        } else {

            echo 1;
        }
    }

    public function logout() {
        $where = array('user_id' => $this->session->userdata('UserId'));
        $data_array = array('csrf_token' => "", 'modify_date' => date('Y-m-d H:i:s'));
        $update_id = $this->query->update('users', $data_array, $where);

        $user_data = $this->session->all_userdata();
        foreach ($user_data as $key => $value) {

            $this->session->unset_userdata($key);
        }
        $this->session->sess_destroy();
        redirect('user', 'refresh');
    }

    public function change_password() {
        $key = $this->uri->segment(3);
        $user = explode("_", $key);
        $user_id = $user[1];
        $where = array('user_id' => $user_id);
        $checkcode = $this->query->get_details('*', 'users', $where);
        $linksenddate = date('Y-m-d', strtotime($checkcode[0]['modify_date']));
        if ($checkcode[0]['token'] == $user[0] && $linksenddate == date('Y-m-d')) {
            if (!empty($key)) {
                if ($this->input->post()) {
                    // $key=$this->input->post('key');

                    $this->form_validation->set_rules('new_password', 'Password', 'required');
                    $this->form_validation->set_rules('confirm_password', 'Confirm-Password', 'required');
                    $this->form_validation->set_rules('confirm_password', 'Confirm-Password', 'matches[new_password]');
                    if ($this->form_validation->run() == FALSE) {
                        $this->template->load('template', 'change_password');
                    } else {
                        $params['password'] = $this->input->post('new_password');
                        $params['user_id'] = $user_id;
                        $api = base_url() . "api/user/change_password";
                        $json_data = json_decode($this->restclient->post($api, $params), true);
                        if ($json_data['status'] == 'success') {
                            $this->session->set_flashdata('success', $json_data['message']);
                            $this->template->load('template', 'login');
                        } else if ($json_data['status'] == 'error') {
                            $this->session->set_flashdata('error', $json_data['message']);
                            $this->template->load('template', 'change_password');
                        }
                    }
                } else {
                    $this->template->load('template', 'change_password');
                }
            } else {
                $this->session->set_flashdata('error', "Not Authorised user");
                $this->template->load('template', 'login');
            }
        } else {
            $this->session->set_flashdata('error', "Not Valid link");
            $this->template->load('template', 'login');
        }
    }

}
