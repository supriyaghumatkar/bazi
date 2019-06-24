$(document).ready(function () {
    var base_url = "http://sharmilamohanan.com/bazi";

//Registration validation
    $("#register-form").validate({
        errorClass: "help-inline text-danger",
        errorElement: "span",
        rules: {
            first_name: {required: true},
            last_name: {required: true},
            email: {required: true, email: true},
            gender: {required: true},
            DOB: {required: true},
            birth_time: {required: true},
            mobile: {required: true, maxlength: 10, number: true},
            password: {
                required: true,
                pwcheck: true,
            },
            confirm_password: {
                required: true,
                equalTo: "#password"
            },
        },
        messages: {
            first_name: {"required": "Enter first name"},
            last_name: {"required": "Enter last name"},
            email: {"required": "Enter email"},
            gender: {"required": "Select gender"},
            DOB: {"required": "Select birth date"},
            birth_time: {"required": "Select birth time"},
            mobile: {"required": "Enter mobile"},
            password: {"required": "Enter password"},
            confirm_password: {
                "required": "Enter confirm password",
                "equalTo": "Confirm password must be match with password."
            },
        }
    });
    
     $("#edit_profile").validate({
        errorClass: "help-inline text-danger",
        errorElement: "span",
        rules: {
            first_name: {required: true},
            last_name: {required: true},
            email: {required: true, email: true},
            gender: {required: true},
            DOB: {required: true},
            birth_time: {required: true},
            mobile: {required: true, maxlength: 10, number: true},
           
        },
        messages: {
            first_name: {"required": "Enter first name"},
            last_name: {"required": "Enter last name"},
            email: {"required": "Enter email"},
            gender: {"required": "Select gender"},
            DOB: {"required": "Select birth date"},
            birth_time: {"required": "Select birth time"},
            mobile: {"required": "Enter mobile"},
        }
    });
    
    
    $.validator.addMethod("pwcheck",
            function (value, element) {
                return /^[A-Za-z0-9\d=!\-@._*]+$/.test(value);
            });

    $("#login-form").validate({
        errorClass: "help-inline text-danger",
        errorElement: "span",
        rules: {
            username: {
                required: true,
                email: true
            },
            password: {
                required: true,
            },

        },
        messages: {
            username: {"required": "Enter email", "email": "Enter valid email"},
            password: {"required": "Enter password"},
        }
    });

    $("#personaldetail-form").validate({
        errorClass: "help-inline text-danger",
        errorElement: "span",
        rules: {
            first_name: {required: true},
            last_name: {required: true},
            gender: {required: true},
            birttdate: {required: true},
           // birthtime: {required: true},
        },
        messages: {
            first_name: {"required": "Enter first name"},
            last_name: {"required": "Enter last name"},
            gender: {"required": "Select gender"},
            birttdate: {"required": "Select birth date"},
           // birthtime: {"required": "Select birth time"},
        }
    });

    
    $("#report-personaldetail-form").validate({
        errorClass: "help-inline text-danger",
        errorElement: "span",
        rules: {
            first_name: {required: true},
            last_name: {required: true},
            gender: {required: true},
            birttdate: {required: true},
           // birthtime: {required: true},
        },
        messages: {
            first_name: {"required": "Enter first name"},
            last_name: {"required": "Enter last name"},
            gender: {"required": "Select gender"},
            birttdate: {"required": "Select birth date"},
           // birthtime: {"required": "Select birth time"},
        }
    });



    $("#chapass-form").validate({
        errorClass: "help-inline text-danger",
        errorElement: "span",
        rules: {
            new_password: {
                required: true,
                pwcheck: true,
            },
            confirm_password: {
                required: true,
                equalTo: "#new_password"
            },
        },
        messages: {
            new_password: {
                "required": "Enter password"
            },
            confirm_password: {
                "required": "Enter confirm password",
                "equalTo": "Confirm password must be match with password."
            },
        }
    });


    $("#email").blur(function () {
        var email = $("#email").val();
        $.ajax({
            url: base_url + "/user/checkEmail",
            type: "POST",
            data: {'email': email},
            datatype: "html",
            async: true,
            cache: false,
            success: function (data)
            {
                //alert(data);
                if (data == 0) {
                    $("#checkemail").html("");
                } else {
                    $("#checkemail").html("Email Id already exist ");
                }
            }
        });
    });

    $("#fogemail").blur(function () {
        var fogemail = $("#fogemail").val();
        $.ajax({
            url: base_url + "/user/checkEmail",
            type: "POST",
            data: {'email': fogemail},
            datatype: "html",
            async: true,
            cache: false,
            success: function (data)
            {
                if (data == 0) {
                    $("#checkfogemail").html("Enter valid email");
                    $('#btn_fogsubmit').prop('disabled', true);
                } else {
                    $("#checkfogemail").html("");
                    $('#btn_fogsubmit').prop('disabled', false);
                }
            }
        });
    });


    $("#btn_fogsubmit").click(function () {

        $("#checkfogemail").html("");
        var fogemail = $("#fogemail").val();
        if (fogemail != "")
        {
            $.ajax({
                url: base_url + "/user/sendmail_forgot_password",
                type: "POST",
                data: {'email': fogemail},
                datatype: "html",
                async: true,
                cache: false,
                success: function (data)
                {
                    if (data == 0)
                    {
                        $("#fg_success").html("Please check your email to reset password");
                        $('#btn_fogsubmit').prop('disabled', true);
                    } else
                    {
                        $("#fg_error").html("Something went wrong.Please try agian or later");
                        $('#btn_fogsubmit').prop('disabled', false);
                    }
                }
            });
        } else
        {
            $("#checkfogemail").html("Please enter valid email");
        }
    });


 //for profile page on checked addition of price    
$('input:checkbox').change(function ()
{
  //alert("dsds");
var total = 0;
      $('input:checkbox:checked').each(function(){
       total +=  isNaN(parseInt($(this).val())) ? 0 : parseInt($(this).val());
      });   
      $("#total").html("$ " +  total);
});




//END DOC READY
});

