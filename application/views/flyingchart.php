<?php 
extract($data);
$SE= $data[0]['SE'];
$SEV=explode(',',$SE);

$S= $data[0]['S'];
$SV=explode(',',$S);

$SW= $data[0]['SW'];
$SWV=explode(',',$SW);

$E= $data[0]['E'];
$EV=explode(',',$E);

$W= $data[0]['W'];
$WV=explode(',',$W);

$NE= $data[0]['NE'];
$NEV=explode(',',$NE);

$N= $data[0]['N'];
$NV=explode(',',$N);

$NW= $data[0]['NW'];
$NWV=explode(',',$NW);

$Middle= $data[0]['Middle'];
$MiddleV=explode(',',$Middle);

$period= $data[0]['period'];
$facing= $data[0]['facing'];
?>

<style>
 #chakraflying{-webkit-transition: all 1s ease-in;
-moz-transition: all 2.5s ease-in;
-ms-transition: all 2.5s ease-in;
-o-transition: all 2.5s ease-in;
transition: all 2.5s ease-in;transform:rotate(0deg);}
            </style>
            <div class="labling"><p>Facing <?php echo $facing; ?></p></div>
<div style="background-image: url(http://localhost/bazi/assets/images/Floor-Plan.png); background-size: contain;background-position: center; position:relative;">
 
 <div id="chakraflying" class="chakra"><?php $this->load->view('flyingstarsvg.php');?>
</div>
 </div>
 <div>
 <table align="center" style="width: 50%; margin:10% auto; border-collapse: collapse;" cellspacing="0">
  <tbody>
    <tr>
      <td>
        <table style="border: 1px solid;" cellpadding="0" cellspacing="0" align="center" valign="top">
          <tbody>
            <tr height="30px" style="border-collapse: collapse; border: 0px;">
              <td colspan="2" align="left" style="background-color: #db4360;; color: white; font-weight: bold; padding-left: 5px; ">
                SE
              </td>
              <td colspan="1" align="center" style="background-color: #db4360;; color: white; font-weight: bold;">
                S
              </td>
              <td colspan="2" align="right" style="background-color: #db4360;; color: white; font-weight: bold;padding-right: 5px;">
                SW
              </td>
            </tr>
            <tr height="100px">
              <td width="30px" align="center" style="background-color: #db4360;; color: white; font-weight: bold; border: 0px solid; border-collapse: collapse">
              </td>
              <td width="180px" style="border: 1px solid black; border-collapse: collapse; border-right-width: 0px; border-bottom-width: 0px">
                <table cellpadding="0" cellspacing="0" align="center" valign="top">
                  <tbody>
                    <tr height="60px">
                      <td align="center" colspan="3">
                        <table>
                          <tbody>
                            <tr>
                              <td align="left" width="60px">
                                <table style="width: 50%">
                                  <tbody>
                                    <tr>
                                      <td align="center" style="font-size: 22px; font-family: sans-serif; font-weight: normal;">
                                        <a>
                                          <?php echo $SEV[1]; ?>
                                        </a>
                                      </td>
                                    </tr>
                                  </tbody>
                                </table>
                              </td>
                              <td align="center" width="60px">
                              </td>
                              <td align="center" width="60px">
                                <table style="width: 100%">
                                  <tbody>
                                    <tr>
                                      <td align="center" style="font-size: 22px; font-family: sans-serif; font-weight: normal;">
                                        <a>
                                          <?php echo $SEV[2]; ?>
                                        </a>
                                      </td>
                                    </tr>
                                  </tbody>
                                </table>
                              </td>
                            </tr>
                          </tbody>
                        </table>
                      </td>
                    </tr>
                    <tr height="60px">
                      <td>
                        <table>
                          <tbody>
                            <tr>
                              <td align="left" width="60px">
                              </td>
                              <td align="center" width="60px">
                                <table style="width: 100%">
                                  <tbody>
                                    <tr>
                                      <td align="center" style="font-size: 36px; font-family: sans-serif; font-weight: normal;">
                                        <a>
                                          <?php echo $SEV[0]; ?>
                                        </a>
                                      </td>
                                    </tr>
                                  </tbody>
                                </table>
                              </td>
                              <td align="center" width="60px">
                              </td>
                            </tr>
                          </tbody>
                        </table>
                      </td>
                    </tr>
                    <tr height="60px" style="margin-top: 0px;">
                      <td align="center" colspan="3">
                        <table>
                          <tbody>
                            <tr>
                              <td align="left" width="60px">
                              </td>
                              <td align="center" width="60px">
                              </td>
                              <td align="center" width="60px">
                              </td>
                            </tr>
                          </tbody>
                        </table>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </td>
              <td width="180px" style="border: 1px solid black; border-collapse: collapse; border-bottom-width: 0px;">
                <table cellpadding="0" cellspacing="0" align="center" valign="top">
                  <tbody>
                    <tr height="60px">
                      <td align="center" colspan="3">
                        <table>
                          <tbody>
                            <tr>
                              <td align="left" width="60px">
                                <table style="width: 100%">
                                  <tbody>
                                    <tr>
                                      <td align="center" style="font-size: 22px; font-family: sans-serif; font-weight: normal;">
                                        <a>
                                          <?php echo $SV[1]; ?>
                                        </a>
                                      </td>
                                    </tr>
                                  </tbody>
                                </table>
                              </td>
                              <td align="center" width="60px">
                              </td>
                              <td align="center" width="60px">
                                <table style="width: 100%">
                                  <tbody>
                                    <tr>
                                      <td align="center" style="font-size: 22px; font-family: sans-serif; font-weight: normal;">
                                        <a>
                                          <?php echo $SV[2]; ?>
                                        </a>
                                      </td>
                                    </tr>
                                  </tbody>
                                </table>
                              </td>
                            </tr>
                          </tbody>
                        </table>
                      </td>
                    </tr>
                    <tr height="60px">
                      <td>
                        <table>
                          <tbody>
                            <tr>
                              <td align="left" width="60px">
                              </td>
                              <td align="center" width="60px">
                                <table style="width: 100%">
                                  <tbody>
                                    <tr>
                                      <td align="center" style="font-size: 36px; font-family: sans-serif; font-weight: normal;">
                                        <a>
                                          <?php echo $SV[0]; ?>
                                        </a>
                                      </td>
                                    </tr>
                                  </tbody>
                                </table>
                              </td>
                              <td align="center" width="60px">
                              </td>
                            </tr>
                          </tbody>
                        </table>
                      </td>
                    </tr>
                    <tr height="60px" style="margin-top: 0px;">
                      <td align="center" colspan="3">
                        <table>
                          <tbody>
                            <tr>
                              <td align="left" width="60px">
                              </td>
                              <td align="center" width="60px">
                              </td>
                              <td align="center" width="60px">
                              </td>
                            </tr>
                          </tbody>
                        </table>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </td>
              <td width="180px" style="border: 1px solid black; border-collapse: collapse;border-left-width: 0px; border-bottom-width: 0px">
                <table cellpadding="0" cellspacing="0" align="center" valign="top">
                  <tbody>
                    <tr height="60px">
                      <td align="center" colspan="3">
                        <table>
                          <tbody>
                            <tr>
                              <td align="left" width="60px">
                                <table style="width: 100%">
                                  <tbody>
                                    <tr>
                                      <td align="center" style="font-size: 22px; font-family: sans-serif; font-weight: normal;">
                                        <a>
                                          <?php echo $SWV[1]; ?>
                                        </a>
                                      </td>
                                    </tr>
                                  </tbody>
                                </table>
                              </td>
                              <td align="center" width="60px">
                              </td>
                              <td align="center" width="60px">
                                <table style="width: 100%">
                                  <tbody>
                                    <tr>
                                      <td align="center" style="font-size: 22px; font-family: sans-serif; font-weight: normal;">
                                        <a>
                                          <?php echo $SWV[2]; ?>
                                        </a>
                                      </td>
                                    </tr>
                                  </tbody>
                                </table>
                              </td>
                            </tr>
                          </tbody>
                        </table>
                      </td>
                    </tr>
                    <tr height="60px">
                      <td>
                        <table>
                          <tbody>
                            <tr>
                              <td align="left" width="60px">
                              </td>
                              <td align="center" width="60px">
                                <table style="width: 100%">
                                  <tbody>
                                    <tr>
                                      <td align="center" style="font-size: 36px; font-family: sans-serif; font-weight: normal;">
                                        <a>
                                          <?php echo $SWV[0]; ?>
                                        </a>
                                      </td>
                                    </tr>
                                  </tbody>
                                </table>
                              </td>
                              <td align="center" width="60px">
                              </td>
                            </tr>
                          </tbody>
                        </table>
                      </td>
                    </tr>
                    <tr height="60px" style="margin-top: 0px;">
                      <td align="center" colspan="3">
                        <table>
                          <tbody>
                            <tr>
                              <td align="left" width="60px">
                              </td>
                              <td align="center" width="60px">
                              </td>
                              <td align="center" width="60px">
                              </td>
                            </tr>
                          </tbody>
                        </table>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </td>
              <td width="30px" align="center" style="background-color: #db4360;; color: white; font-weight: bold; border: 0px; border-collapse: collapse">
              </td>
            </tr>
            <tr height="100px">
              <td width="30px" align="center" style="background-color: #db4360;; color: white; font-weight: bold; border: 0px; border-collapse: collapse">
                E
              </td>
              <td width="180px" style="border: 1px solid black; border-collapse: collapse; border-right-width: 0px;">
                <table cellpadding="0" cellspacing="0" align="center" valign="top">
                  <tbody>
                    <tr height="60px">
                      <td align="center" colspan="3">
                        <table>
                          <tbody>
                            <tr>
                              <td align="left" width="60px">
                                <table style="width: 100%">
                                  <tbody>
                                    <tr>
                                      <td align="center" style="font-size: 22px; font-family: sans-serif; font-weight: normal;">
                                        <a>
                                          <?php echo $EV[1]; ?>
                                        </a>
                                      </td>
                                    </tr>
                                  </tbody>
                                </table>
                              </td>
                              <td align="center" width="60px">
                              </td>
                              <td align="center" width="60px">
                                <table style="width: 100%">
                                  <tbody>
                                    <tr>
                                      <td align="center" style="font-size: 22px; font-family: sans-serif; font-weight: normal;">
                                        <a>
                                          <?php echo $EV[2]; ?>
                                        </a>
                                      </td>
                                    </tr>
                                  </tbody>
                                </table>
                              </td>
                            </tr>
                          </tbody>
                        </table>
                      </td>
                    </tr>
                    <tr height="60px">
                      <td>
                        <table>
                          <tbody>
                            <tr>
                              <td align="left" width="60px">
                              </td>
                              <td align="center" width="60px">
                                <table style="width: 100%">
                                  <tbody>
                                    <tr>
                                      <td align="center" style="font-size: 36px; font-family: sans-serif; font-weight: normal;">
                                        <a>
                                          <?php echo $EV[0]; ?>
                                        </a>
                                      </td>
                                    </tr>
                                  </tbody>
                                </table>
                              </td>
                              <td align="center" width="60px">
                              </td>
                            </tr>
                          </tbody>
                        </table>
                      </td>
                    </tr>
                    <tr height="60px" style="margin-top: 0px;">
                      <td align="center" colspan="3">
                        <table>
                          <tbody>
                            <tr>
                              <td align="left" width="60px">
                              </td>
                              <td align="center" width="60px">
                              </td>
                              <td align="center" width="60px">
                              </td>
                            </tr>
                          </tbody>
                        </table>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </td>
              <td width="180px" style="border: 1px solid; border-collapse: collapse">
                <table cellpadding="0" cellspacing="0" align="center" valign="top">
                  <tbody>
                    <tr height="60px">
                      <td align="center" colspan="3">
                        <table>
                          <tbody>
                            <tr>
                              <td align="left" width="60px">
                                <table style="width: 100%">
                                  <tbody>
                                    <tr>
                                      <td align="center" style="font-size: 22px; font-family: sans-serif; font-weight: normal;">
                                        <a>
                                          <?php echo $MiddleV[1]; ?>
                                        </a>
                                      </td>
                                    </tr>
                                  </tbody>
                                </table>
                              </td>
                              <td align="center" width="60px">
                              </td>
                              <td align="center" width="60px">
                                <table style="width: 100%">
                                  <tbody>
                                    <tr>
                                      <td align="center" style="font-size: 22px; font-family: sans-serif; font-weight: normal;">
                                        <a>
                                          <?php echo $MiddleV[2]; ?>
                                        </a>
                                      </td>
                                    </tr>
                                  </tbody>
                                </table>
                              </td>
                            </tr>
                          </tbody>
                        </table>
                      </td>
                    </tr>
                    <tr height="60px">
                      <td>
                        <table>
                          <tbody>
                            <tr>
                              <td align="left" width="60px">
                              </td>
                              <td align="center" width="60px">
                                <table style="width: 100%">
                                  <tbody>
                                    <tr>
                                      <td align="center" style="font-size: 36px; font-family: sans-serif; font-weight: normal;">
                                        <a>
                                          <?php echo $MiddleV[0]; ?>
                                        </a>
                                      </td>
                                    </tr>
                                  </tbody>
                                </table>
                              </td>
                              <td align="center" width="60px">
                              </td>
                            </tr>
                          </tbody>
                        </table>
                      </td>
                    </tr>
                    <tr height="60px" style="margin-top: 0px;">
                      <td align="center" colspan="3">
                        <table>
                          <tbody>
                            <tr>
                              <td align="left" width="60px">
                              </td>
                              <td align="center" width="60px">
                              </td>
                              <td align="center" width="60px">
                              </td>
                            </tr>
                          </tbody>
                        </table>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </td>
              <td width="180px" style="border: 1px solid black; border-collapse: collapse; border-left-width: 0px;">
                <table cellpadding="0" cellspacing="0" align="center" valign="top">
                  <tbody>
                    <tr height="60px">
                      <td align="center" colspan="3">
                        <table>
                          <tbody>
                            <tr>
                              <td align="left" width="60px">
                                <table style="width: 100%">
                                  <tbody>
                                    <tr>
                                      <td align="center" style="font-size: 22px; font-family: sans-serif; font-weight: normal;">
                                        <a>
                                          <?php echo $WV[1]; ?>
                                        </a>
                                      </td>
                                    </tr>
                                  </tbody>
                                </table>
                              </td>
                              <td align="center" width="60px">
                              </td>
                              <td align="center" width="60px">
                                <table style="width: 100%">
                                  <tbody>
                                    <tr>
                                      <td align="center" style="font-size: 22px; font-family: sans-serif; font-weight: normal;">
                                        <a>
                                          <?php echo $WV[2]; ?>
                                        </a>
                                      </td>
                                    </tr>
                                  </tbody>
                                </table>
                              </td>
                            </tr>
                          </tbody>
                        </table>
                      </td>
                    </tr>
                    <tr height="60px">
                      <td>
                        <table>
                          <tbody>
                            <tr>
                              <td align="left" width="60px">
                              </td>
                              <td align="center" width="60px">
                                <table style="width: 100%">
                                  <tbody>
                                    <tr>
                                      <td align="center" style="font-size: 36px; font-family: sans-serif; font-weight: normal;">
                                        <a>
                                          <?php echo $WV[0]; ?>
                                        </a>
                                      </td>
                                    </tr>
                                  </tbody>
                                </table>
                              </td>
                              <td align="center" width="60px">
                              </td>
                            </tr>
                          </tbody>
                        </table>
                      </td>
                    </tr>
                    <tr height="60px" style="margin-top: 0px;">
                      <td align="center" colspan="3">
                        <table>
                          <tbody>
                            <tr>
                              <td align="left" width="60px">
                              </td>
                              <td align="center" width="60px">
                              </td>
                              <td align="center" width="60px">
                              </td>
                            </tr>
                          </tbody>
                        </table>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </td>
              <td width="30px" align="center" style="background-color: #db4360;; color: white; font-weight: bold; border: 0px; border-top: none; border-collapse: collapse">
                W
              </td>
            </tr>
            <tr height="100px">
              <td width="30px" align="center" style="background-color: #db4360;; color: white; font-weight: bold; border: 0px; border-collapse: collapse">
              </td>
              <td width="180px" style="border: 1px solid black; border-collapse: collapse; border-right-width: 0px; border-top-width: 0px">
                <table cellpadding="0" cellspacing="0" align="center" valign="top">
                  <tbody>
                    <tr height="60px">
                      <td align="center" colspan="3">
                        <table>
                          <tbody>
                            <tr>
                              <td align="left" width="60px">
                                <table style="width: 100%">
                                  <tbody>
                                    <tr>
                                      <td align="center" style="font-size: 22px; font-family: sans-serif; font-weight: normal;">
                                        <a>
                                          <?php echo $NEV[1]; ?>
                                        </a>
                                      </td>
                                    </tr>
                                  </tbody>
                                </table>
                              </td>
                              <td align="center" width="60px">
                              </td>
                              <td align="center" width="60px">
                                <table style="width: 100%">
                                  <tbody>
                                    <tr>
                                      <td align="center" style="font-size: 22px; font-family: sans-serif; font-weight: normal;">
                                        <a>
                                          <?php echo $NEV[2]; ?>
                                        </a>
                                      </td>
                                    </tr>
                                  </tbody>
                                </table>
                              </td>
                            </tr>
                          </tbody>
                        </table>
                      </td>
                    </tr>
                    <tr height="60px">
                      <td>
                        <table>
                          <tbody>
                            <tr>
                              <td align="left" width="60px">
                              </td>
                              <td align="center" width="60px">
                                <table style="width: 100%">
                                  <tbody>
                                    <tr>
                                      <td align="center" style="font-size: 36px; font-family: sans-serif; font-weight: normal;">
                                        <a>
                                          <?php echo $NEV[0]; ?>
                                        </a>
                                      </td>
                                    </tr>
                                  </tbody>
                                </table>
                              </td>
                              <td align="center" width="60px">
                              </td>
                            </tr>
                          </tbody>
                        </table>
                      </td>
                    </tr>
                    <tr height="60px" style="margin-top: 0px;">
                      <td align="center" colspan="3">
                        <table>
                          <tbody>
                            <tr>
                              <td align="left" width="60px">
                              </td>
                              <td align="center" width="60px">
                              </td>
                              <td align="center" width="60px">
                              </td>
                            </tr>
                          </tbody>
                        </table>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </td>
              <td width="180px" style="border: 1px solid black; border-collapse: collapse; border-top-width: 0px;">
                <table cellpadding="0" cellspacing="0" align="center" valign="top">
                  <tbody>
                    <tr height="60px">
                      <td align="center" colspan="3">
                        <table>
                          <tbody>
                            <tr>
                              <td align="left" width="60px">
                                <table style="width: 100%">
                                  <tbody>
                                    <tr>
                                      <td align="center" style="font-size: 22px; font-family: sans-serif; font-weight: normal;">
                                        <a>
                                          <?php echo $NV[1]; ?>
                                        </a>
                                      </td>
                                    </tr>
                                  </tbody>
                                </table>
                              </td>
                              <td align="center" width="60px">
                              </td>
                              <td align="center" width="60px">
                                <table style="width: 100%">
                                  <tbody>
                                    <tr>
                                      <td align="center" style="font-size: 22px; font-family: sans-serif; font-weight: normal;">
                                        <a>
                                          <?php echo $NV[2]; ?>
                                        </a>
                                      </td>
                                    </tr>
                                  </tbody>
                                </table>
                              </td>
                            </tr>
                          </tbody>
                        </table>
                      </td>
                    </tr>
                    <tr height="60px">
                      <td>
                        <table>
                          <tbody>
                            <tr>
                              <td align="left" width="60px">
                              </td>
                              <td align="center" width="60px">
                                <table style="width: 100%">
                                  <tbody>
                                    <tr>
                                      <td align="center" style="font-size: 36px; font-family: sans-serif; font-weight: normal;">
                                        <a>
                                          <?php echo $NV[0]; ?>
                                        </a>
                                      </td>
                                    </tr>
                                  </tbody>
                                </table>
                              </td>
                              <td align="center" width="60px">
                              </td>
                            </tr>
                          </tbody>
                        </table>
                      </td>
                    </tr>
                    <tr height="60px" style="margin-top: 0px;">
                      <td align="center" colspan="3">
                        <table>
                          <tbody>
                            <tr>
                              <td align="left" width="60px">
                              </td>
                              <td align="center" width="60px">
                              </td>
                              <td align="center" width="60px">
                              </td>
                            </tr>
                          </tbody>
                        </table>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </td>
              <td width="180px" style="border: 1px solid black; border-collapse: collapse; border-left-width: 0px; border-top-width: 0px">
                <table cellpadding="0" cellspacing="0" align="center" valign="top">
                  <tbody>
                    <tr height="60px">
                      <td align="center" colspan="3">
                        <table>
                          <tbody>
                            <tr>
                              <td align="left" width="60px">
                                <table style="width: 100%">
                                  <tbody>
                                    <tr>
                                      <td align="center" style="font-size: 22px; font-family: sans-serif; font-weight: normal;">
                                        <a>
                                          <?php echo $NWV[1]; ?>
                                        </a>
                                      </td>
                                    </tr>
                                  </tbody>
                                </table>
                              </td>
                              <td align="center" width="60px">
                              </td>
                              <td align="center" width="60px">
                                <table style="width: 100%">
                                  <tbody>
                                    <tr>
                                      <td align="center" style="font-size: 22px; font-family: sans-serif; font-weight: normal;">
                                        <a>
                                          <?php echo $NWV[2]; ?>
                                        </a>
                                      </td>
                                    </tr>
                                  </tbody>
                                </table>
                              </td>
                            </tr>
                          </tbody>
                        </table>
                      </td>
                    </tr>
                    <tr height="60px">
                      <td>
                        <table>
                          <tbody>
                            <tr>
                              <td align="left" width="60px">
                              </td>
                              <td align="center" width="60px">
                                <table style="width: 100%">
                                  <tbody>
                                    <tr>
                                      <td align="center" style="font-size: 36px; font-family: sans-serif; font-weight: normal;">
                                        <a>
                                          <?php echo $NWV[0]; ?>
                                        </a>
                                      </td>
                                    </tr>
                                  </tbody>
                                </table>
                              </td>
                              <td align="center" width="60px">
                              </td>
                            </tr>
                          </tbody>
                        </table>
                      </td>
                    </tr>
                    <tr height="60px" style="margin-top: 0px;">
                      <td align="center" colspan="3">
                        <table>
                          <tbody>
                            <tr>
                              <td align="left" width="60px">
                              </td>
                              <td align="center" width="60px">
                              </td>
                              <td align="center" width="60px">
                              </td>
                            </tr>
                          </tbody>
                        </table>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </td>
              <td width="30px" align="center" style="background-color: #db4360;; color: white; font-weight: bold; border: 0px; border-collapse: collapse">
              </td>
            </tr>
            <tr height="30px">
              <td colspan="2" align="left" style="background-color: #db4360;; color: white; font-weight: bold; padding-left: 5px;">
                NE
              </td>
              <td align="center" style="background-color: #db4360;; color: white; font-weight: bold;">
                N
                <span style="font-size: 40px; margin-left: -15px; margin-top: 20px; color: black; position: absolute">
                  ↓
                </span>
              </td>
              <td colspan="2" align="right" style="background-color: #db4360;; color: white; font-weight: bold; padding-right: 5px;">
                NW
              </td>
            </tr>
          </tbody>
        </table>
      </td>
    </tr>
  </tbody>
</table>

 </div>





 <!-- <script src="<?php echo get_assets_path(); ?>newcssjs/js/jquery-2.1.4.min.js"></script> -->
<script>         
 $(document).ready(function(){
    //$("#chakraflying").css("transform", "rotate(0deg)");
    
    //debugger;

        var millisecondsToWait = 1000;
        setTimeout(function() {
            // Whatever you want to do after the wait
            $("#southn1").text("<?php echo $SV[0]; ?>");
            $("#southn2").text("<?php echo $SV[1]; ?>");
            $("#southn3").text("<?php echo $SV[2]; ?>");

            $("#southwn1").text("<?php echo $SWV[0]; ?>");
            $("#southwn2").text("<?php echo $SWV[1]; ?>");
            $("#southwn3").text("<?php echo $SWV[2]; ?>");

            $("#northn1").text("<?php echo $NV[0]; ?>");
            $("#northn2").text("<?php echo $NV[1]; ?>");
            $("#northn3").text("<?php echo $NV[2]; ?>");

            $("#westn1").text("<?php echo $WV[0]; ?>");
            $("#westn2").text("<?php echo $WV[1]; ?>");
            $("#westn3").text("<?php echo $WV[2]; ?>");

            $("#eastn1").text("<?php echo $EV[0]; ?>");
            $("#eastn2").text("<?php echo $EV[1]; ?>");
            $("#eastn3").text("<?php echo $EV[2]; ?>");

            $("#northen1").text("<?php echo $NEV[0]; ?>");
            $("#northen2").text("<?php echo $NEV[1]; ?>");
            $("#northen3").text("<?php echo $NEV[2]; ?>");

            $("#southen1").text("<?php echo $SEV[0]; ?>");
            $("#southen2").text("<?php echo $SEV[1]; ?>");
            $("#southen3").text("<?php echo $SEV[2]; ?>");

            $("#northwn1").text("<?php echo $NWV[0]; ?>");
            $("#northwn2").text("<?php echo $NWV[1]; ?>");
            $("#northwn3").text("<?php echo $NWV[2]; ?>");


            var facingDirection='<?php echo $facing; ?>'
    //alert(facingDirection);
     if(facingDirection=="S" || facingDirection=="S1" || facingDirection=="S2" || facingDirection=="S3")
     {
        $("#chakraflying").css("transform", "rotate(0deg)");
     }
      if(facingDirection=="SE" || facingDirection=="SE1" || facingDirection=="SE2" || facingDirection=="SE3")
     {
        $("#chakraflying").css("transform", "rotate(48deg)");
     }
      if(facingDirection=="E" || facingDirection=="E1" || facingDirection=="E2" || facingDirection=="E3")
     {
        $("#chakraflying").css("transform", "rotate(88deg)");
     }
      if(facingDirection=="NE" || facingDirection=="NE1" || facingDirection=="NE2" || facingDirection=="NE3")
     {
        $("#chakraflying").css("transform", "rotate(138deg)");
     }
     if(facingDirection=="N" || facingDirection=="N1" || facingDirection=="N2" || facingDirection=="N3")
     {
        $("#chakraflying").css("transform", "rotate(183deg)");
     }
     if(facingDirection=="NW" || facingDirection=="NW1" || facingDirection=="NW2" || facingDirection=="NW3")
     {
        $("#chakraflying").css("transform", "rotate(228deg)");
     }
      if(facingDirection=="W" || facingDirection=="W1" || facingDirection=="W2" || facingDirection=="W3")
     {
        $("#chakraflying").css("transform", "rotate(270deg)");
     }
     if(facingDirection=="SW" || facingDirection=="SW1" || facingDirection=="SW2" || facingDirection=="SW3")
     {
        $("#chakraflying").css("transform", "rotate(318deg)");
     }
        }, millisecondsToWait);

     
 });
</script>