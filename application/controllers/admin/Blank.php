<?php 
(defined('BASEPATH')) OR exit('No direct script access allowed'); 
/**
 * Description of site
 */
class Blank extends CI_Controller {
 
 	function __construct() 
	{
        parent::__construct();			
		
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
				$this->template->load('admin/template', 'admin/blank');
			}	
    }
    

	
}
