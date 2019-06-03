<?php 
(defined('BASEPATH')) OR exit('No direct script access allowed'); 
/**
 * Description of site
 */
class Dashboard extends CI_Controller {
 
 	function __construct() 
	{
        parent::__construct();			
        $this->load->model('admin/dashboard_model');	
	}
	
	
    public function index() 
	{
            $isLoggedIn = $this->session->userdata('isLoggedIn');
            
           if(!isset($isLoggedIn) || $isLoggedIn != TRUE)
            {
		   
		    	redirect('admin/login');
			}
			else{
                $data['page_title'] ="Dashbard"; 
                $data['user_name'] = $this->session->userdata('name');
				$this->template->load('admin/template','admin/dashboard',$data);
			}	
    }
    

	
}
