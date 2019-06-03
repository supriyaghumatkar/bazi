<?php 
(defined('BASEPATH')) OR exit('No direct script access allowed'); 
/**
 * Description of site
 */
class Register extends CI_Controller {
 
 	function __construct() 
	{
		parent::__construct();	
		
		$this->load->model('admin/register_model');
		
		
	}
    public function index() 
	{
		   $isLoggedIn = $this->session->userdata('isLoggedIn');
           if(!isset($isLoggedIn) || $isLoggedIn != TRUE)
            {
		   
		    	redirect('admin/login');
			}
			else{
           
		        $data['userdetail'] = $this->register_model->get_register_user_detail();
				$data['page_title'] ="Register User"; 
				$this->template->load('admin/template','admin/registeruser',$data);
			}	
	}
	
	public function delete_user()
	{
		$isLoggedIn = $this->session->userdata('isLoggedIn');
           if(!isset($isLoggedIn) || $isLoggedIn != TRUE)
            {
		   
		    	redirect('admin/login');
			}
			else{
		$user_id=$this->uri->segment(4);
		$delete=$this->register_model->delete_user($user_id);
		if($delete)
		{
		//$this->session->set_flashdata('success','User Deleted Successfully');
		redirect('admin/register');
		}
	}

	}
   
}
