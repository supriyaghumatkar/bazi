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

class Profile extends REST_Controller {

    function __construct() {
        parent::__construct();
        
    }
    

    public function UserDetail_post() {
        $user_id=$this->input->post('user_id');
        $where = array('user_id' => $user_id);
        $userdetail = $this->query->get_details('*', 'users', $where);
            if (is_array($userdetail) && !empty($userdetail)) {
                $this->response(['status' => 'success', 'message' => '', 'data' =>$userdetail], REST_Controller::HTTP_OK);

        }
    }

    public function edit_profile_post() {
        $updateUser = array(
            'FirstName' => $this->input->post('FirstName'),
            'LastName' => $this->input->post('LastName'),
            'Mobile' => $this->input->post('Mobile'),
            'Gender' => $this->input->post('Gender'),
            'BirthDate' => $this->input->post('BirthDate'),
            'BirthTime' => $this->input->post('BirthTime'),   
        );
        $where  	= array('user_id'=>$this->input->post('user_id'));	 		
        $update_id  = $this->query->update('users',$updateUser,$where);
        if($update_id)
        {
            $this->response(['status' => 'success', 'message' => 'Your profile Updated Successfully', 'data' =>''], REST_Controller::HTTP_OK);

        }
    }


   
}