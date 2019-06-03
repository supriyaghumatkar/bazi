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

class User extends REST_Controller {

    function __construct() {
        parent::__construct();
        
    }
    
     public function signup_post() {
        
          $subscriptionId = $this->fechFreeSubscriptionId_get();
          $insertUser = array(
                'FirstName' => html_escape($this->input->post('FirstName')),
                'LastName' => html_escape($this->input->post('LastName')),
                'Email' => html_escape($this->input->post('Email')),
                'Password' => html_escape(md5($this->input->post('Password'))),
                'Mobile' => html_escape($this->input->post('Mobile')),
                'Gender' => html_escape($this->input->post('Gender')),
                'BirthDate' => html_escape($this->input->post('BirthDate')),
                'BirthTime' => html_escape($this->input->post('BirthTime')),
                'UserSubscriptionId' => $subscriptionId,
            ); 
            $username = $this->checkEmail_get(html_escape($this->input->post('Email')));
            if($username==0)
            {
                $inertuser=$this->insertUser($insertUser);
                if(!empty($inertuser))
                {				
                    $msg = "Thank You for Registration! <br/>
                    You have successfully registered with us.";

                    $this->response(['status' =>'success','message' => $msg], REST_Controller::HTTP_OK);         
                }
            }
        else {
            $this->response(['status' =>'error','message' => "Email ID Already Exist"], REST_Controller::HTTP_OK);       
        }
     } 
     
     public function signin_post()
     {
         
                $userName = $this->input->post('userName');
                $password = $this->input->post('password');
                $csrftoken=$this->input->post('login_token');
             //check into table
                $validUser = $this->checkLogin_get($userName, $password);
           
                if (!empty($validUser)) {   
                    $where  	= array('user_id'=>$validUser->user_id);	
				    $data_array = array('csrf_token'=>$csrftoken,'modify_date'=>date('Y-m-d H:i:s'));				
                    $update_id  = $this->query->update('users',$data_array,$where);
                    log_message("error","userapi".$csrftoken);
                    //set logged in users details in session
                    $loginSessionData = array(
                        'UserId' => $validUser->user_id,
                        'Email' => $validUser->Email,
                        'subscription_type'=>$validUser->UserSubscriptionId,
                        'IsLogin'=>'true',
                        'Token'=> $csrftoken,
                    );
						
                   $this->response(['status' =>'success','message' => '','data'=>$loginSessionData,'userdetail'=>$validUser], REST_Controller::HTTP_OK);               
                } else {
                   $this->response(['status' =>'error','message' => "Please enter correct Username or Password."], REST_Controller::HTTP_OK);  
                    
                }
         
     }
     //common function  
     public function fechFreeSubscriptionId_get() {
        $this->db->select('subscription_id');
        $this->db->where('plantype', 'Free');
        $subscription = $this->db->get('subscription_plan')->row();
        return $subscription->subscription_id;
    }

//    public function checkUserName_get($username) {
//        $this->db->select('userId');
//        $this->db->where('UserName', $username);
//        return $this->db->get('users')->num_rows();
//    }

    public function checkEmail_get($email) {
        $this->db->select('user_id');
        $this->db->where('Email', $email);
        return $this->db->get('users')->num_rows();
    }

    public function insertUser($data) {
        $this->db->insert('users', $data);
        return TRUE;
    }

    public function checkLogin_get($userName, $password) {
        $this->db->select('*');
        //$this->db->group_start();
        $this->db->where('Email', $userName);
        //$this->db->or_where('Email', $userName);
        //$this->db->group_end();
        $this->db->where('Password', md5($password));
        return $this->db->get('users')->row();
    }
    
    public function change_password_post()
    {
        $user_id = $this->input->post('user_id');
        $password = md5($this->input->post('password'));
        $data_array = array('Password'=>$password,'modify_date'=>date('Y-m-d H:i:s'));
	$result = $this->query->update('users',$data_array,array('user_id'=>$user_id));
        if($result){
                   $this->response(['status' =>'success','message' => 'Password is Updated Successfully'], REST_Controller::HTTP_OK);               
                } else {
                   $this->response(['status' =>'error','message' => "Password is Not Updated Successfully"], REST_Controller::HTTP_OK);  
                    
                }
         
    }
    
}