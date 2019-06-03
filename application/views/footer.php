<!-- footer -->
<div class="footer">
        <div class="copyright">
            <p>Copyright &copy; 2019 SHARMILA MOHANAN BAZI APP All Right Reserved. | <span>Follow us on
                <a href="https://www.facebook.com/sharmila.mohanan.3" target="_blank">
                    <i class="fa fa-facebook"></i>
                </a>
                <a href="#">
                    <i class="fa fa-instagram"></i>
                </a>
                <a href="#">
                    <i class="fa fa-linkedin"></i>
                </a></span></p> 
            <p>Designed & Developed by <a href="http://www.blink-interact.com/" target="_blank">Blinkinteract</a></p>
        </div>
    </div>
    <!-- //footer -->
<script src="<?php echo get_assets_path(); ?>newcssjs/js/jquery-2.1.4.min.js"></script>

<script src="<?php echo get_assets_path(); ?>newcssjs/js/bootstrap.min.js"></script>

<!-- ace scripts -->
<script src="<?php echo get_assets_path(); ?>newcssjs/js/ace-elements.min.js"></script>
<script src="<?php echo get_assets_path(); ?>newcssjs/js/ace.min.js"></script>


<script src="<?php echo get_assets_path(); ?>newcssjs/js/jquery-validation/js/jquery.validate.min.js" type="text/javascript"></script>
     <script src="<?php echo get_assets_path(); ?>newcssjs/js/jquery-validation/js/additional-methods.min.js" type="text/javascript"></script>


<script src="<?php echo get_assets_path(); ?>newcssjs/js/jquery-ui.custom.min.js"></script>		
<script src="<?php echo get_assets_path(); ?>newcssjs/js/bootstrap-datepicker.min.js"></script>	
<script src="<?php echo get_assets_path(); ?>newcssjs/js/timepicki.js"></script>	
<script src="<?php echo get_assets_path(); ?>newcssjs/js/moment.min.js"></script>
<script src="<?php echo get_assets_path(); ?>newcssjs/js/daterangepicker.min.js"></script>

<!-- moving-top scrolling -->
<script type="text/javascript" src="<?php echo get_assets_path(); ?>newcssjs/js/move-top.js"></script>
<script type="text/javascript" src="<?php echo get_assets_path(); ?>newcssjs/js/easing.js"></script>


<script src="<?php echo get_assets_path(); ?>newcssjs/js/main.js"></script>

<!-- inline scripts related to this page -->
<script type="text/javascript">
    jQuery(function ($) {
      

        //datepicker plugin
        //link
        $('.date-picker').datepicker({
         autoclose: true,
         todayHighlight: true,
         }) 
    
        //or change it into a date range picker
       // $('.input-daterange').datepicker({autoclose: true});


        //to translate the daterange picker, please copy the "examples/daterange-fr.js" contents here before initialization
        $('.date-range-picker').daterangepicker({
            'applyClass': 'btn-sm btn-success',
            'cancelClass': 'btn-sm btn-default',
            locale: {
                applyLabel: 'Apply',
                cancelLabel: 'Cancel',
                format: 'DD/MM/YYYY',
            },
        })
                .prev().on(ace.click_event, function () {
            $(this).next().focus();
        });

         $('#timepicker1').timepicki();
         $('#timepicker2').timepicki();


        /* 	if(!ace.vars['old_ie']) $('#date-timepicker1').datetimepicker({
         //format: 'MM/DD/YYYY h:mm:ss A',//use this option to display seconds
         icons: {
         time: 'fa fa-clock-o',
         date: 'fa fa-calendar',
         up: 'fa fa-chevron-up',
         down: 'fa fa-chevron-down',
         previous: 'fa fa-chevron-left',
         next: 'fa fa-chevron-right',
         today: 'fa fa-arrows ',
         clear: 'fa fa-trash',
         close: 'fa fa-times'
         }
         }).next().on(ace.click_event, function(){
         $(this).prev().focus();
         }); */


        /* $('#colorpicker1').colorpicker();
         //$('.colorpicker').last().css('z-index', 2000);//if colorpicker is inside a modal, its z-index should be higher than modal'safe
                         
         $('#simple-colorpicker-1').ace_colorpicker();
         //$('#simple-colorpicker-1').ace_colorpicker('pick', 2);//select 2nd color
         //$('#simple-colorpicker-1').ace_colorpicker('pick', '#fbe983');//select #fbe983 color
         //var picker = $('#simple-colorpicker-1').data('ace_colorpicker')
         //picker.pick('red', true);//insert the color if it doesn't exist
                         
                         
         $(".knob").knob();
         */
      
    });
</script>

<script>
    $(function () {

        $('#login-form-link').click(function (e) {
            $("#login-form").delay(100).fadeIn(100);
            $("#register-form").fadeOut(100);
            $('#register-form-link').removeClass('active');
            $(this).addClass('active');
            e.preventDefault();
        });
        $('#register-form-link').click(function (e) {
            $("#register-form").delay(100).fadeIn(100);
            $("#login-form").fadeOut(100);
            $('#login-form-link').removeClass('active');
            $(this).addClass('active');
            e.preventDefault();
        });

    });
</script>

</body>
</html>
