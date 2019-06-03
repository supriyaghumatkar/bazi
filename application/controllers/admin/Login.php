<?php 
(defined('BASEPATH')) OR exit('No direct script access allowed'); 
/**
 * Description of site 
 */
class Login extends CI_Controller {
	
	protected $_module;
 
    public function __construct()
    {
        parent::__construct();
        $this->load->model('admin/login_model');
    }
    /**
     * Index Page for this controller.
     */
    public function index()
    {
    	$this->session->set_userdata('');
         $isLoggedIn = $this->session->userdata('isLoggedIn');
        if(!isset($isLoggedIn) || $isLoggedIn != TRUE)
        {
            $this->load->view('admin/login');
           
	    
        }
        else
        {
            $this->template->load('admin/template', 'admin/dashboard');
        }
    }
    
   
   public function loginMe()
    {
       $clientcode =$this->input->post('clientcode');
        $this->load->library('form_validation');
        
        $this->form_validation->set_rules('user_name', 'Username', 'required|trim');
        $this->form_validation->set_rules('user_pass', 'Password', 'required');
        
        if($this->form_validation->run() == FALSE)
        {

        	 $this->load->view('admin/login'); 
       }
        else
        {
        	
            $email = $this->input->post('user_name');
            $password = $this->input->post('user_pass');
            
            $result = $this->login_model->loginMe($email,$password);
           
            if(count($result) > 0)
            {
            	extract($result);
                   
			    	  	     $sessionArray = array('user_id'=>$result[0]['admin_id'],                   
                                            'email'=>$result[0]['email'],
                                            'name'=>$result[0]['name'],
                                            'isLoggedIn' => TRUE,    
                                    );   
                		
                    $this->session->set_userdata($sessionArray);
                    redirect('admin/dashboard');
            }
            else
            {
            	$this->session->set_flashdata('error','Username or password mismatch');
                redirect('admin/login');
            }
        }
    }
	
	public function logout() 
	{	
		$redirecturl='admin/login';
        $user_data = $this->session->all_userdata();
        foreach ($user_data as $key => $value) {

            $this->session->unset_userdata($key);
        }
        $this->session->sess_destroy();
		redirect($redirecturl);
		exit;
	}
}