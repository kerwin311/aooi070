# Prog. Version..: '5.30.08-13.07.05(00010)'     #
#
# Pattern name...: aooi070.4gl
# Descriptions...: 每日匯率維護作業
# Date & Author..: 91/09/09 By Lin
# Modify.........: No.MOD-470041 04/07/20 By Nicola 修改INSERT INTO 語法
# Modify.........: No.MOD-480240 04/08/10 By Nicola 更改資料後，複製有問題
# Modify.........: No.MOD-470515 04/10/05 By Nicola 加入"相關文件"功能
# Modify ........: No.FUN-4C0016 04/12/02 By ching 單價,金額改成 DEC(20,6)
# Modify.........: No.FUN-4C0083 04/12/16 By pengu  匯率幣別欄位修改，與aoos010的aza17做判斷，
                                                    #如果二個幣別相同時，匯率強制為 1
# Modify.........: No.FUN-510027 05/02/03 By pengu 報表轉XML
# Modify.........: No.MOD-580242 05/09/12 By Nicola PAGE LENGTH g_line 改為g_page_line
# Modify.........: No.FUN-640012 06/04/06 By kim GP3.0 匯率參數功能改善
# Modify.........: No.MOD-650015 06/05/05 By rainy 取消輸入時的"預設上筆"功能
# Modify.........: No.FUN-660131 06/06/19 By Cheunl cl_err --> cl_err3
# Modify.........: No.FUN-680102 06/08/28 By zdyllq 類型轉換 
# Modify.........: No.FUN-6A0015 06/10/25 By jamie FUNCTION _q() 一開始應清空key值
# Modify.........: No.FUN-6A0081 06/11/01 By atsea l_time轉g_time
# Modify.........: No.TQC-720007 07/03/06 By Smapmin 刪除後要同步更新azj_file,azk_file
# Modify.........: No.TQC-6B0105 07/03/07 By carrier 連續兩次查詢,第二次查不到資料,做修改等操作會將當前筆停在上次查詢到的資料上
# Modify.........: No.FUN-740074 07/04/23 By jacklai 透過java抓取台銀網站的匯率純文字檔匯入azk_file
# Modify.........: No.FUN-750051 07/05/22 By johnray 連續二次查詢key值時,若第二次查詢不到key值時,會顯示錯誤key值
# Modify.........: No.TQC-750176 07/05/25 By jacklai 修正匯入失敗未顯示提示訊息, 及最後一筆資料無對應幣別資料時整個交易會失敗
# Modify.........: No.FUN-760083 07/07/06 By mike 報表格式修改為crystal reports
# Modify.........: No.MOD-780110 07/08/17 By kim 無法修改,複製,刪除
# Modify.........: No.MOD-850007 08/05/05 By Smapmin 自動匯入時,應保留原本azk051/azk052的設定
# Modify.........: No.MOD-860281 08/07/04 By Sarah 自動匯入時,需CALL i070_mth()
# Modify.........: No.FUN-960067 09/06/09 By jacklai 自動匯入時l_date改抓g_today
# Modify.........: No.FUN-960178 09/06/30 By jacklai 將偵測檔案結束改為iseof()
# Modify.........: No.FUN-980030 09/08/31 By Hiko 加上GP5.2的相關設定
# Modify.........: No.FUN-950087 10/02/22 By vealxu 新增時匯率default值調整
# Modify.........: No.FUN-9B0098 10/02/24 by tommas delete cl_doc
# Modify.........: No.FUN-B10021 11/01/17 by jrg542 自動匯入時加呼叫海關匯率
# Modify.........: No:MOD-A90018 10/09/06 By Summer 增加azj041,azj051,azj052的insert
# Modify.........: No.MOD-B40107 11/04/19 by sabrina 自動匯入時會出現兩次詢問視窗
# Modify.........: No.FUN-B50063 11/05/26 By xianghui BUG修改，刪除時提取資料報400錯誤
# Modify.........: No:FUN-B80035 11/08/03 By Lujh 模組程序撰寫規範修正
# Modify.........: No:MOD-B90162 11/09/22 By johung 幣別無效時不CALL i070_mth()
# Modify.........: No.FUN-BB0047 11/12/30 By fengrui  調整時間函數問題 
# Modify.........: No:FUN-C80046 12/08/13 By bart 複製後停在新料號畫面
# Modify.........: No.CHI-B60062 12/08/27 By Vampire 若抓下來的資料檔"旬"不屬於該區段，則改抓該區段的第一天資料寫入
# Modify.........: No:CHI-C20056 12/08/27 By Vampire 5-10,15-20,25-31改抓當旬最後一筆
# Modify.........: No:MOD-C90236 12/10/15 By Vampire 第三旬須修正為+21與+24
# Modify.........: No:CHI-D20022 13/04/10 By bart 改抓取海關匯率歷史資料
# Modify.........: No:MOD-D40190 13/04/25 By bart mark LET l_filepath = l_msg
# Modify.........: No:MOD-D50003 13/05/02 By bart l_azk051和l_azk052為空或0時給l_azk的值
#190124 kerwin  s_jget_excustrate 181217 失效 直接抓關務署匯率

DATABASE ds
 
GLOBALS "../../config/top.global"
 
DEFINE
    g_azk   RECORD LIKE azk_file.*,
    g_azk_t RECORD LIKE azk_file.*,
    g_azk01_t LIKE azk_file.azk01,
    g_azk02_t LIKE azk_file.azk02,
    g_wc,g_sql          STRING     #NO.TQC-630166     
 
DEFINE g_forupd_sql STRING   #SELECT ... FOR UPDATE SQL     
DEFINE g_before_input_done   LIKE type_file.num5          #No.FUN-680102 SMALLINT
DEFINE   g_chr           LIKE type_file.chr1          #No.FUN-680102 VARCHAR(1)
DEFINE   g_cnt           LIKE type_file.num10         #No.FUN-680102 INTEGER
DEFINE   g_i             LIKE type_file.num5     #count/index for any purpose        #No.FUN-680102 SMALLINT
DEFINE   g_msg           LIKE type_file.chr1000       #No.FUN-680102 VARCHAR(72)
DEFINE   g_row_count    LIKE type_file.num10         #No.FUN-680102 INTEGER
DEFINE   g_curs_index   LIKE type_file.num10         #No.FUN-680102 INTEGER
DEFINE   g_jump         LIKE type_file.num10         #No.FUN-680102 INTEGER
DEFINE   g_no_ask       LIKE type_file.num5          #No.FUN-680102 SMALLINT
DEFINE   g_argv1         LIKE type_file.chr1          #No.FUN-740074 #參數1 是否為背景作業
DEFINE   g_argv2         STRING                       #No.FUN-740074 #參數2 (1.現金 2.即期)
DEFINE   g_argv3         STRING                       #No.FUN-740074 #參數3 資料存在是否覆寫 (Y:覆寫, N:取消執行) 
DEFINE   g_argv4         STRING                       #No.FUN-740074 #參數4 執行功能
DEFINE   l_table         STRING                       #No.FUN-760083
DEFINE   g_str           STRING                       #No.FUN-760083
DEFINE   g_flag          LIKE type_file.chr1          #CHI-C20056 add
 
MAIN
   IF FGL_GETENV("FGLGUI") <> "0" THEN #No.FUN-740074
      OPTIONS
         INPUT NO WRAP
   DEFER INTERRUPT
   END IF #No.FUN-740074
   
   LET g_argv1 = ARG_VAL(1)
   LET g_argv2 = ARG_VAL(2)
   LET g_argv3 = ARG_VAL(3)
   LET g_argv4 = ARG_VAL(4)
   LET g_bgjob = g_argv1
   
   IF (NOT cl_user()) THEN
      EXIT PROGRAM
   END IF
 
   WHENEVER ERROR CALL cl_err_msg_log
 
   IF (NOT cl_setup("AOO")) THEN
      EXIT PROGRAM
   END IF
 
    #CALL  cl_used(g_prog,g_time,1) RETURNING g_time #No.MOD-580088  HCN 20050818  #No.FUN-6A0081 #FUN-BB0047 mark
    INITIALIZE g_azk.* TO NULL
    INITIALIZE g_azk_t.* TO NULL
 
    LET g_sql="azk01.azk_file.azk01,",
              "azi02.azi_file.azi02,",
              "azk02.azk_file.azk02,",
              "azk03.azk_file.azk03,",
              "azk04.azk_file.azk04,",
              "azk041.azk_file.azk041,",
              "azk051.azk_file.azk051,",
              "azk052.azk_file.azk052,",
              "azi07.azi_file.azi07"
    LET l_table=cl_prt_temptable("aooi070",g_sql) CLIPPED
    IF l_table=-1 THEN EXIT PROGRAM END IF
    LET g_sql="INSERT INTO ",g_cr_db_str CLIPPED,l_table CLIPPED,
              " VALUES(?,?,?,?,?,?,?,?,?)"
   PREPARE insert_prep FROM g_sql
   IF STATUS THEN
     CALL cl_err("insert_prep:",status,1)
   END IF
 
   CALL  cl_used(g_prog,g_time,1) RETURNING g_time #FUN-BB0047 add
   LET g_forupd_sql = "SELECT * FROM azk_file  WHERE azk01=? AND azk02=? FOR UPDATE " #MOD-780110
   LET g_forupd_sql = cl_forupd_sql(g_forupd_sql)
   DECLARE i070_cl CURSOR FROM g_forupd_sql              # LOCK CURSOR     #MOD-780110

   IF g_bgjob='N' OR cl_null(g_bgjob) THEN #No.FUN-740074
      OPEN WINDOW i070_w WITH FORM "aoo/42f/aooi070"
         ATTRIBUTE (STYLE = g_win_style CLIPPED) #No.FUN-580092 HCN
      CALL cl_ui_init()
   END IF #No.FUN-740074
   
    IF g_aza.aza19='1' THEN CALL cl_err('','aoo-059',0) END IF
      
    IF NOT cl_null(g_argv1) THEN
       CASE g_argv4
         WHEN "auto_import"
            LET g_flag = 'Y'     #CHI-C20056 add
            CALL i070_get_java_exrate()
            IF g_flag = 'Y' THEN #CHI-C20056 add
               CALL i070_get_java_excustomsrate()
            END IF               #CHI-C20056 add
            EXIT PROGRAM
       END CASE
    END IF 
    
    LET g_action_choice=""
    CALL i070_menu()
 
    CLOSE WINDOW i070_w

    CALL cl_used(g_prog,g_time,2) RETURNING g_time 
END MAIN
 
FUNCTION i070_cs()
    CLEAR FORM
   INITIALIZE g_azk.* TO NULL    #No.FUN-750051
    CONSTRUCT BY NAME g_wc ON                     #螢幕上取條件
              azk01,azk02,azk04,azk03,azk041,azk051,azk052  #,azk05 #FUN-640012 mark
              #No.FUN-580031 --start--     HCN
              BEFORE CONSTRUCT
                 CALL cl_qbe_init()
              #No.FUN-580031 --end--       HCN
 
        ON ACTION controlp
           CASE
              WHEN INFIELD(azk01) #啟梗
#                CALL q_azi(10,5,g_azk.azk01) RETURNING g_azk.azk01
                 CALL cl_init_qry_var()
                 LET g_qryparam.form = "q_azi"
                 LET g_qryparam.state = "c"
                 LET g_qryparam.default1 = g_azk.azk01
#                CALL cl_create_qry() RETURNING g_azk.azk01
#                DISPLAY BY NAME g_azk.azk01
                 CALL cl_create_qry() RETURNING g_qryparam.multiret
                 DISPLAY g_qryparam.multiret TO azk01
                 NEXT FIELD azk01
              OTHERWISE EXIT CASE
           END CASE
       ON IDLE g_idle_seconds
          CALL cl_on_idle()
          CONTINUE CONSTRUCT
 
      ON ACTION about         #MOD-4C0121
         CALL cl_about()      #MOD-4C0121
 
      ON ACTION help          #MOD-4C0121
         CALL cl_show_help()  #MOD-4C0121
 
      ON ACTION controlg      #MOD-4C0121
         CALL cl_cmdask()     #MOD-4C0121
 
 
		#No.FUN-580031 --start--     HCN
                 ON ACTION qbe_select
         	   CALL cl_qbe_select()
                 ON ACTION qbe_save
		   CALL cl_qbe_save()
		#No.FUN-580031 --end--       HCN
    END CONSTRUCT
##
 
    IF INT_FLAG THEN RETURN END IF
    #資料權限的檢查
    #Begin:FUN-980030
    #    IF g_priv2='4' THEN                           #只能使用自己的資料
    #        LET g_wc = g_wc clipped," AND azkuser = '",g_user,"'"
    #    END IF
    #    IF g_priv3='4' THEN                           #只能使用相同群的資料
    #        LET g_wc = g_wc clipped," AND azkgrup MATCHES '",g_grup CLIPPED,"*'"
    #    END IF
 
    #    IF g_priv3 MATCHES "[5678]" THEN    #TQC-5C0134群組權限
    #        LET g_wc = g_wc clipped," AND azkgrup IN ",cl_chk_tgrup_list()
    #    END IF
    LET g_wc = g_wc CLIPPED,cl_get_extra_cond('azkuser', 'azkgrup')
    #End:FUN-980030
 
    LET g_sql="SELECT azk01,azk02 FROM azk_file ", # 組合出 SQL 指令
              " WHERE ",g_wc CLIPPED, " ORDER BY azk01,azk02"
    PREPARE i070_prepare FROM g_sql           # RUNTIME 編譯
    DECLARE i070_cs                         # SCROLL CURSOR
        SCROLL CURSOR WITH HOLD FOR i070_prepare
    LET g_sql=
        "SELECT COUNT(*) FROM azk_file WHERE ",g_wc CLIPPED
    PREPARE i070_precount FROM g_sql
    DECLARE i070_count CURSOR FOR i070_precount
END FUNCTION
 
FUNCTION i070_menu()
    MENU ""
 
        BEFORE MENU
            CALL cl_navigator_setting( g_curs_index, g_row_count )
 
        ON ACTION insert
            LET g_action_choice="insert"
            IF cl_chk_act_auth() THEN
               CALL i070_a()
            END IF
        ON ACTION query
            LET g_action_choice="query"
            IF cl_chk_act_auth() THEN
               CALL i070_q()
            END IF
 
        ON ACTION next
            CALL i070_fetch('N')
        ON ACTION previous
            CALL i070_fetch('P')
        ON ACTION jump
            CALL i070_fetch('/')
        ON ACTION first
            CALL i070_fetch('F')
        ON ACTION last
            CALL i070_fetch('L')
 
        ON ACTION modify
            LET g_action_choice="modify"
            IF cl_chk_act_auth() THEN
               CALL i070_u()
            END IF
        ON ACTION delete
            LET g_action_choice="delete"
            IF cl_chk_act_auth() THEN
               CALL i070_r()
            END IF
       ON ACTION reproduce
            LET g_action_choice="reproduce"
            IF cl_chk_act_auth() THEN
               CALL i070_copy()
            END IF
       ON ACTION output
            LET g_action_choice="output"
            IF cl_chk_act_auth() THEN
               CALL i070_out()
            END IF
        ON ACTION help
            CALL cl_show_help()
        ON ACTION locale
           CALL cl_dynamic_locale()
          CALL cl_show_fld_cont()                   #No.FUN-550037 hmf

        ON ACTION exit
            LET g_action_choice = "exit"
            EXIT MENU
 
       ON IDLE g_idle_seconds
          CALL cl_on_idle()
 
      ON ACTION about         #MOD-4C0121
         CALL cl_about()      #MOD-4C0121
 
      ON ACTION controlg      #MOD-4C0121
         CALL cl_cmdask()     #MOD-4C0121
 
         ON ACTION related_document    #No.MOD-470515
           LET g_action_choice="related_document"
           IF cl_chk_act_auth() THEN
              IF g_azk.azk01 IS NOT NULL THEN
                 LET g_doc.column1 = "azk01"
                 LET g_doc.value1 = g_azk.azk01
                 LET g_doc.column2 = "azk02"
                 LET g_doc.value2 = g_azk.azk02
                 CALL cl_doc()
              END IF
           END IF
           
        #No.FUN-740074 --start--
        ON ACTION auto_import
           LET g_action_choice = "auto_import"
           IF cl_chk_act_auth() THEN
              LET g_flag = 'Y'     #CHI-C20056 add
              CALL i070_get_java_exrate()
              IF g_flag = 'Y' THEN #CHI-C20056 add
	         CALL i070_get_java_excustomsrate()
              END IF               #CHI-C20056 add
           END IF
        #No.FUN-740074 --end--
        
        -- for Windows close event trapped
        ON ACTION close   #COMMAND KEY(INTERRUPT) #FUN-9B0145  
             LET INT_FLAG=FALSE 		#MOD-570244	mars
            LET g_action_choice = "exit"
            EXIT MENU
    END MENU
    CLOSE i070_cs
END FUNCTION
 
 
FUNCTION i070_a()
    IF s_shut(0) THEN RETURN END IF
    MESSAGE ""
    CLEAR FORM                                   # 清螢墓欄位內容
    INITIALIZE g_azk.* LIKE azk_file.*
    LET g_azk01_t = NULL
    LET g_azk02_t = NULL
#%  LET g_azk.xxxx = 0				# DEFAULT
    LET g_azk.azk02=g_today
#    LET g_azk.azk03=1  #FUN-950087 mark
#    LET g_azk.azk04=1  #FUN-950087 mark
#    LET g_azk.azk041=1 #FUN-950087 mark
#    LET g_azk.azk051=1 #FUN-950087 mark
#    LET g_azk.azk052=1 #FUN-950087 mark
    #LET g_azk.azk05=1  #FUN-640012 mark
    CALL cl_opmsg('a')
    WHILE TRUE
        CALL i070_i("a")                      # 各欄位輸入
        IF INT_FLAG THEN                         # 若按了DEL鍵
            INITIALIZE g_azk.* TO NULL
            LET INT_FLAG = 0
            CALL cl_err('',9001,0)
            CLEAR FORM
            EXIT WHILE
        END IF
        IF g_azk.azk01 IS NULL THEN                # KEY 不可空白
            CONTINUE WHILE
        END IF
        INSERT INTO azk_file VALUES(g_azk.*)       # DISK WRITE
        IF SQLCA.sqlcode THEN
            LET g_msg=g_azk.azk01 CLIPPED,'+',g_azk.azk02
#           CALL cl_err(g_msg,SQLCA.sqlcode,0)   #No.FUN-660131
            CALL cl_err3("ins","azk_file",g_msg,"",SQLCA.sqlcode,"","",1)  #No.FUN-660131
            CONTINUE WHILE
        ELSE
            LET g_azk_t.* = g_azk.*                # 保存上筆資料
            SELECT azk01 INTO g_azk.azk01 FROM azk_file
                WHERE azk01 = g_azk.azk01 AND azk02 = g_azk.azk02
        END IF
        CALL i070_mth()
        EXIT WHILE
    END WHILE
    LET g_wc=' '
END FUNCTION
 
FUNCTION i070_i(p_cmd)
   DEFINE   p_cmd    LIKE type_file.chr1,          #No.FUN-680102 VARCHAR(1)
            l_flag   LIKE type_file.chr1,     #判斷必要欄位之值是否有輸入        #No.FUN-680102 VARCHAR(1)
            l_n      LIKE type_file.num5          #No.FUN-680102 SMALLINT
 
   INPUT BY NAME
      g_azk.azk01,g_azk.azk02,g_azk.azk03,g_azk.azk04,g_azk.azk041,
      g_azk.azk051,g_azk.azk052  #,g_azk.azk05 #FUN-640012 mark
      WITHOUT DEFAULTS
 
      BEFORE INPUT
          LET g_before_input_done = FALSE
          CALL i070_set_entry(p_cmd)
          CALL i070_set_no_entry(p_cmd)
          LET g_before_input_done = TRUE
 
      AFTER FIELD azk01                 #幣別代碼
         IF g_azk.azk01 IS NOT NULL THEN
            IF g_azk01_t IS NULL OR
               (g_azk.azk01 != g_azk01_t ) THEN
               CALL i070_azk01('a')
               IF g_chr='E' THEN
                  CALL cl_err(g_azk.azk01,'aoo-011',0)
                  LET g_azk.azk01 = g_azk01_t
                  DISPLAY BY NAME g_azk.azk01
                  NEXT FIELD azk01
               #No.FUN-950087 ---start----
               ELSE
                  LET g_azk.azk03 = 1
                  LET g_azk.azk04 = 1
                  LET g_azk.azk041 = 1
                  LET g_azk.azk051 = 1
                  LET g_azk.azk052 = 1
                  IF g_azk.azk01 != g_aza.aza17 THEN
                     LET g_sql = " SELECT azk03,azk04,azk041,azk051,azk052 FROM azk_file ",
                                 "  WHERE azk01 = '",g_azk.azk01,"'",
                                 "    AND azk051 > 0 AND azk052 > 0 ",
                                 "  ORDER BY azk02 DESC "
                     PREPARE i070_pre01 FROM g_sql
                     DECLARE i070_curs01 CURSOR FOR i070_pre01

                     FOREACH i070_curs01 INTO g_azk.azk03,g_azk.azk04,g_azk.azk041,g_azk.azk051,g_azk.azk052
                        IF SQLCA.sqlcode THEN
                           CALL cl_err('foreach:',SQLCA.sqlcode,1)
                           EXIT FOREACH
                        ELSE
                           EXIT FOREACH
                        END IF
                     END FOREACH
                  END IF
                  DISPLAY BY NAME g_azk.azk03,g_azk.azk04,g_azk.azk041,g_azk.azk051,g_azk.azk052 
               #No.FUN-950087 ---end---
               END IF
            END IF
         END IF
 
      AFTER FIELD azk02                  #日期
       IF g_azk.azk02 IS NOT NULL THEN
         IF p_cmd = "a" OR                    # 若輸入或更改且改KEY
            (p_cmd = "u" AND (g_azk.azk01 != g_azk01_t OR g_azk.azk02 != g_azk02_t)) THEN
            SELECT count(*) INTO l_n FROM azk_file WHERE azk01 = g_azk.azk01 AND azk02 = g_azk.azk02
            IF l_n > 0 THEN                  # Duplicated
               LET g_msg=g_azk.azk01 CLIPPED,'+',g_azk.azk02
               CALL cl_err(g_msg,-239,0)
               LET g_azk.azk01 = g_azk01_t
               LET g_azk.azk02 = g_azk02_t
               DISPLAY BY NAME g_azk.azk01
               DISPLAY BY NAME g_azk.azk02
               NEXT FIELD azk01
            END IF
         END IF
       END IF
 
      AFTER FIELD azk03                   #銀行賣出匯率
         IF g_azk.azk03 IS NULL OR g_azk.azk03 < 0  THEN
            NEXT FIELD azk03
         END IF
 
         #FUN-4C0083
         IF g_azk.azk03 IS NOT NULL THEN
            IF g_azk.azk01=g_aza.aza17 THEN
               LET g_azk.azk03 =1
               DISPLAY BY NAME g_azk.azk03
            END IF
         END IF
         #--END
 
      AFTER FIELD azk04                   #銀行買入匯率
         IF g_azk.azk04 IS NULL OR g_azk.azk04 < 0  THEN
            NEXT FIELD azk04
         END IF
 
         #FUN-4C0083
         IF g_azk.azk04 IS NOT NULL THEN
            IF g_azk.azk01=g_aza.aza17 THEN
               LET g_azk.azk04 =1
               DISPLAY BY NAME g_azk.azk04
            END IF
         END IF
         #--END
 
      AFTER FIELD azk041                 #銀行中價匯率
         IF g_azk.azk041 IS NULL OR g_azk.azk041< 0  THEN
            NEXT FIELD azk041
         END IF
 
         #FUN-4C0083
         IF g_azk.azk041 IS NOT NULL THEN
            IF g_azk.azk01=g_aza.aza17 THEN
               LET g_azk.azk041 =1
               DISPLAY BY NAME g_azk.azk041
            END IF
         END IF
         #--END
 
      AFTER FIELD azk051                  #海關買入匯率
         IF g_azk.azk051 IS NULL OR g_azk.azk051< 0  THEN
            NEXT FIELD azk051
         END IF
 
         #FUN-4C0083
         IF g_azk.azk051 IS NOT NULL THEN
            IF g_azk.azk01=g_aza.aza17 THEN
               LET g_azk.azk051 =1
               DISPLAY BY NAME g_azk.azk051
            END IF
         END IF
         #--END
 
      AFTER FIELD azk052                  #海關賣出匯率
         IF g_azk.azk052 IS NULL OR g_azk.azk052< 0  THEN
            NEXT FIELD azk052
         END IF
 
         #FUN-4C0083
         IF g_azk.azk052 IS NOT NULL THEN
            IF g_azk.azk01=g_aza.aza17 THEN
               LET g_azk.azk052 =1
               DISPLAY BY NAME g_azk.azk052
            END IF
         END IF
         #--END
 
      #mark by FUN-640012...............begin
      #AFTER FIELD azk05                  #海關旬匯率
      #   IF g_azk.azk05 IS NULL OR g_azk.azk05 < 0  THEN
      #      NEXT FIELD azk05
      #   END IF
      #mark by FUN-640012...............end
 
      AFTER INPUT  #判斷必要欄位之值是否有值,若無則反白顯示,並要求重新輸入
         LET l_flag='N'
         IF INT_FLAG THEN
            EXIT INPUT
         END IF
         IF g_azk.azk01 IS NULL OR g_azk.azk01=' ' THEN  #幣別代碼
            LET l_flag='Y'
            DISPLAY BY NAME g_azk.azk01
         END IF
         IF g_azk.azk02 IS NULL OR g_azk.azk02=' '  THEN   #日期
            LET l_flag='Y'
            DISPLAY BY NAME g_azk.azk02
         END IF
         IF g_azk.azk03 IS NULL OR g_azk.azk03 < 0  THEN #銀行賣出匯率
            LET l_flag='Y'
            DISPLAY BY NAME g_azk.azk03
         END IF
         IF g_azk.azk04 IS NULL OR g_azk.azk04 < 0  THEN  #銀行買入匯率
            LET l_flag='Y'
            DISPLAY BY NAME g_azk.azk04
         END IF
         IF g_azk.azk041 IS NULL OR g_azk.azk041 < 0  THEN #銀行中價匯率
            LET l_flag='Y'
            DISPLAY BY NAME g_azk.azk041
         END IF
         IF g_azk.azk051 IS NULL OR g_azk.azk051 < 0  THEN #海關買入匯率
            LET l_flag='Y'
            DISPLAY BY NAME g_azk.azk051
         END IF
         IF g_azk.azk052 IS NULL OR g_azk.azk052 < 0  THEN  #海關賣出匯率
            LET l_flag='Y'
            DISPLAY BY NAME g_azk.azk052
         END IF
        #mark by FUN-640012...............begin 
        #IF g_azk.azk05 IS NULL OR g_azk.azk05 < 0  THEN #海關旬匯率
        #   LET l_flag='Y'
        #   DISPLAY BY NAME g_azk.azk05
        #END IF
        #mark by FUN-640012...............end
         IF l_flag='Y' THEN
            CALL cl_err('','9033',0)
            NEXT FIELD azk01
         END IF
 
        #MOD-650015 --start 
      #ON ACTION CONTROLO                        # 沿用所有欄位
      #   IF INFIELD(azk01) THEN
      #      LET g_azk.* = g_azk_t.*
      #      DISPLAY BY NAME g_azk.*
      #      NEXT FIELD azk01
      #   END IF
        #MOD-650015 --end
 
      ON ACTION CONTROLP
         CASE
            WHEN INFIELD(azk01)
               CALL cl_init_qry_var()
               LET g_qryparam.form = "q_azi"
               LET g_qryparam.default1 = g_azk.azk01
               CALL cl_create_qry() RETURNING g_azk.azk01
               DISPLAY BY NAME g_azk.azk01
               NEXT FIELD azk01
 
      #-----NIC-----
            WHEN INFIELD(azk03)
               CALL s_rate(g_azk.azk01,g_azk.azk03) RETURNING g_azk.azk03
               DISPLAY BY NAME g_azk.azk03
               NEXT FIELD azk03
            WHEN INFIELD(azk04)
               CALL s_rate(g_azk.azk01,g_azk.azk04) RETURNING g_azk.azk04
               DISPLAY BY NAME g_azk.azk04
               NEXT FIELD azk04
            WHEN INFIELD(azk041)
               CALL s_rate(g_azk.azk01,g_azk.azk041) RETURNING g_azk.azk041
               DISPLAY BY NAME g_azk.azk041
               NEXT FIELD azk041
           #mark by FUN-640012...............begin 
           #WHEN INFIELD(azk05)
           #   CALL s_rate(g_azk.azk01,g_azk.azk05) RETURNING g_azk.azk05
           #   DISPLAY BY NAME g_azk.azk05
           #   NEXT FIELD azk05
           #mark by FUN-640012...............end
            WHEN INFIELD(azk051)
               CALL s_rate(g_azk.azk01,g_azk.azk051) RETURNING g_azk.azk051
               DISPLAY BY NAME g_azk.azk051
               NEXT FIELD azk051
            WHEN INFIELD(azk052)
               CALL s_rate(g_azk.azk01,g_azk.azk052) RETURNING g_azk.azk052
               DISPLAY BY NAME g_azk.azk052
               NEXT FIELD azk052
      #-----NIC END-----
            OTHERWISE
               EXIT CASE
         END CASE
 
   ON ACTION CONTROLR
      CALL cl_show_req_fields()
      ON ACTION CONTROLG
         CALL cl_cmdask()
 
      ON ACTION CONTROLF                        # 欄位說明
         CALL cl_set_focus_form(ui.Interface.getRootNode()) RETURNING g_fld_name,g_frm_name #Add on 040913
         CALL cl_fldhelp(g_frm_name,g_fld_name,g_lang) #Add on 040913
 
 
      ON IDLE g_idle_seconds
         CALL cl_on_idle()
         CONTINUE INPUT
 
      ON ACTION about         #MOD-4C0121
         CALL cl_about()      #MOD-4C0121
 
      ON ACTION help          #MOD-4C0121
         CALL cl_show_help()  #MOD-4C0121
 
 
   END INPUT
END FUNCTION
 
FUNCTION i070_mth()     #將輸入的每日匯率做本月的加總
DEFINE
        l_day_cnt    LIKE type_file.num5,        #No.FUN-680102SMALLINT,
        l_azk03      LIKE azk_file.azk03,        #No.FUN-680102 DEC(20,10), #FUN-4C0016
        l_azk04      LIKE azk_file.azk04,        #No.FUN-680102 DEC(20,10), #FUN-4C0016
        l_azk041     LIKE azk_file.azk041,       #No.FUN-680102 DEC(20,10), #FUN-4C0016
        #l_azk05     DEC(20,10),                 #FUN-4C0016 mark by FUN-640012
        l_azk051     LIKE azk_file.azk051,       #No.FUN-680102 DEC(20,10), #FUN-4C0016
        l_azk052     LIKE azk_file.azk052,       #No.FUN-680102 DEC(20,10), #FUN-4C0016
        l_date       LIKE type_file.chr8,        #No.FUN-680102CHAR(08),
        l_b,l_e,l_d  LIKE type_file.dat,         #No.FUN-680102DATE, 
        l_date1      LIKE type_file.chr6         #No.FUN-680102CHAR(06)
 
     MESSAGE " Monthly averaging ! "
     LET l_date = g_azk.azk02 USING 'yyyymmdd'
     LET l_date[7,8] = '01'
     LET l_b = MDY(l_date[5,6],l_date[7,8],l_date[1,4])
 
     LET l_date = g_azk.azk02 USING 'yyyymmdd'
     IF l_date[5,6] = '12'
        THEN LET l_date[1,4] = (l_date[1,4] + 1) USING '&&&&'
             LET l_date[5,8] = '0101'
        ELSE LET l_date[5,6] = (l_date[5,6] + 1) USING '&&'
             LET l_date[7,8] = '01'
     END IF
     LET l_e = MDY(l_date[5,6],l_date[7,8],l_date[1,4]) LET l_e = l_e - 1
 
    #SELECT COUNT(*),SUM(azk03),SUM(azk04) INTO l_day_cnt,l_azk03,l_azk04      #MOD-A90018 mark
     SELECT COUNT(*),SUM(azk03),SUM(azk04),SUM(azk041),SUM(azk051),SUM(azk052) #MOD-A90018 
       INTO l_day_cnt,l_azk03,l_azk04,l_azk041,l_azk051,l_azk052               #MOD-A90018
          FROM azk_file
       WHERE azk02 between l_b and l_e AND azk01 = g_azk.azk01
     LET l_azk03 = l_azk03 / l_day_cnt
     LET l_azk04 = l_azk04 / l_day_cnt
     #MOD-A90018 add --start--
     LET l_azk041 = l_azk041 / l_day_cnt
     LET l_azk051 = l_azk051 / l_day_cnt
     LET l_azk052 = l_azk052 / l_day_cnt
     #MOD-A90018 add --end--
#    CALL cl_dtoc(g_azk.azk02) RETURNING l_date
     LET l_date = g_azk.azk02 USING "yyyymmdd"
     LET l_date1 = l_date[1,6]
 
     UPDATE azj_file SET azj03=l_azk03,azj04=l_azk04
                        ,azj041=l_azk041,azj051=l_azk051,azj052=l_azk052 #MOD-A90018 add
           WHERE azj01 = g_azk.azk01 AND azj02 =l_date1
     IF SQLCA.SQLERRD[3]=0 THEN
         INSERT INTO azj_file(azj01,azj02,azj03,azj04,azj05,azj06,  #No.MOD-470041
                              azj041,azj051,azj052, #MOD-A90018 add
                             azjacti,azjuser,azjgrup,azjmodu,azjdate,azjoriu,azjorig)
             VALUES(g_azk.azk01,l_date1,l_azk03,l_azk04,'','',
                    l_azk041,l_azk051,l_azk052, #MOD-A90018 add
                    'Y',g_user,g_grup,'',g_today, g_user, g_grup)      #No.FUN-980030 10/01/04  insert columns oriu, orig
     END IF
 
     MESSAGE " Latest Ex.rate Updating ! "
     SELECT azk03,azk04,azk041,azk051,azk052  #,azk05 #FUN-640012 mark
       INTO l_azk03,l_azk04,l_azk041,l_azk051,l_azk052 FROM azk_file #,l_azk05 #FUN-640012 mark
      WHERE azk01 = g_azk.azk01
        AND azk02 = ( SELECT MAX(azk02) FROM azk_file
                      WHERE azk01 = g_azk.azk01
                        #AND azk02 >= g_azk.azk02   #TQC-720007
                        AND azk02 < MDY(12,31,9999))
     UPDATE azk_file
        SET azk03 =l_azk03,azk04=l_azk04,
            azk041=l_azk041,  #azk05=l_azk05, #FUN-640012 mark
            azk051=l_azk051,azk052=l_azk052
      WHERE azk01 = g_azk.azk01 AND azk02 = MDY(12,31,9999)
     IF SQLCA.SQLERRD[3]=0 THEN
        LET l_d=MDY(12,31,9999)
         INSERT INTO azk_file (azk01,azk02,azk03,azk04,azk041,  #No.MOD-470041  #azk05, #FUN-640012 mark
                              azk051,azk052)
             VALUES (g_azk.azk01,l_d,l_azk03,l_azk04,l_azk041,  #l_azk05,  #FUN-640012 mark
                     l_azk051,l_azk052)
     END IF
     MESSAGE ""
END FUNCTION
 
 
FUNCTION i070_azk01(p_cmd)  #幣別代碼
    DEFINE l_azi02 LIKE azi_file.azi02,
           l_aziacti LIKE azi_file.aziacti,
           p_cmd  LIKE type_file.chr1          #No.FUN-680102 VARCHAR(1)
 
    LET g_chr = ' '
    IF g_azk.azk01 IS NULL THEN
        LET l_azi02=NULL
    ELSE
        SELECT azi02,aziacti
           INTO l_azi02,l_aziacti
           FROM azi_file WHERE azi01 = g_azk.azk01
        IF SQLCA.sqlcode THEN
            LET g_chr = 'E'
            LET l_azi02 = NULL
        ELSE
            IF l_aziacti='N' THEN
                LET g_chr = 'E'
            END IF
        END IF
    END IF
    IF cl_null(g_chr) OR p_cmd='d' THEN
        DISPLAY l_azi02 TO FORMONLY.azi02
    END IF
END FUNCTION
 
FUNCTION i070_q()
 
    LET g_row_count = 0
    LET g_curs_index = 0
    CALL cl_navigator_setting( g_curs_index, g_row_count )
    INITIALIZE g_azk.* TO NULL              #No.FUN-6A0015
    CALL cl_opmsg('q')
    MESSAGE ""
    DISPLAY '   ' TO FORMONLY.cnt
    CALL i070_cs()                          # 宣告 SCROLL CURSOR
    IF INT_FLAG THEN
        LET INT_FLAG = 0
        CLEAR FORM
        RETURN
    END IF
    MESSAGE " Searching! "
    OPEN i070_count
    FETCH i070_count INTO g_row_count
    DISPLAY g_row_count TO FORMONLY.cnt
    OPEN i070_cs                            # 從DB產生合乎條件TEMP(0-30秒)
    IF SQLCA.sqlcode THEN
        LET g_msg=g_azk.azk01 CLIPPED,'+',g_azk.azk02
        CALL cl_err(g_msg,SQLCA.sqlcode,0)
        INITIALIZE g_azk.* TO NULL
    ELSE
        CALL i070_fetch('F')                  # 讀出TEMP第一筆並顯示
    END IF
    MESSAGE ""
END FUNCTION
 
FUNCTION i070_fetch(p_flazk)
    DEFINE
        p_flazk         LIKE type_file.chr1,         #No.FUN-680102 VARCHAR(1), 
        l_abso          LIKE type_file.num10         #No.FUN-680102 INTEGER
 
    CASE p_flazk
        WHEN 'N' FETCH NEXT     i070_cs INTO g_azk.azk01,
                                                              g_azk.azk02
        WHEN 'P' FETCH PREVIOUS i070_cs INTO g_azk.azk01,
                                                              g_azk.azk02
        WHEN 'F' FETCH FIRST    i070_cs INTO g_azk.azk01,
                                                              g_azk.azk02
        WHEN 'L' FETCH LAST     i070_cs INTO g_azk.azk01,
                                                              g_azk.azk02
        WHEN '/'
            IF (NOT g_no_ask) THEN
               CALL cl_getmsg('fetch',g_lang) RETURNING g_msg
               LET INT_FLAG = 0  ######add for prompt bug
               PROMPT g_msg CLIPPED,': ' FOR g_jump
                  ON IDLE g_idle_seconds
                     CALL cl_on_idle()
 
      ON ACTION about         #MOD-4C0121
         CALL cl_about()      #MOD-4C0121
 
      ON ACTION help          #MOD-4C0121
         CALL cl_show_help()  #MOD-4C0121
 
      ON ACTION controlg      #MOD-4C0121
         CALL cl_cmdask()     #MOD-4C0121
 
               END PROMPT
               IF INT_FLAG THEN
                   LET INT_FLAG = 0
                   EXIT CASE
               END IF
            END IF
            FETCH ABSOLUTE g_jump i070_cs INTO g_azk.azk01,g_azk.azk02
            LET g_no_ask = FALSE
    END CASE
 
    IF SQLCA.sqlcode THEN
        LET g_msg=g_azk.azk01 CLIPPED,'+',g_azk.azk02
        CALL cl_err(g_msg,SQLCA.sqlcode,0)
        INITIALIZE g_azk.* TO NULL  #TQC-6B0105
        LET g_azk.azk01 = NULL      #TQC-6B0105
        RETURN
    ELSE
       CASE p_flazk
          WHEN 'F' LET g_curs_index = 1
          WHEN 'P' LET g_curs_index = g_curs_index - 1
          WHEN 'N' LET g_curs_index = g_curs_index + 1
          WHEN 'L' LET g_curs_index = g_row_count
          WHEN '/' LET g_curs_index = g_jump
       END CASE
 
       CALL cl_navigator_setting( g_curs_index, g_row_count )
    END IF
 
    SELECT * INTO g_azk.* FROM azk_file            # 重讀DB,因TEMP有不被更新特性
     WHERE azk01=g_azk.azk01 AND azk02=g_azk.azk02
    IF SQLCA.sqlcode THEN
        LET g_msg=g_azk.azk01 CLIPPED,'+',g_azk.azk02
#       CALL cl_err(g_msg,SQLCA.sqlcode,0)   #No.FUN-660131
        CALL cl_err3("sel","azk_file",g_msg,"",SQLCA.sqlcode,"","",1)  #No.FUN-660131
    ELSE
 
        CALL i070_show()                      # 重新顯示
    END IF
END FUNCTION
 
FUNCTION i070_show()
    LET g_azk_t.* = g_azk.*
    ##FUN-640012...............begin
    #DISPLAY BY NAME g_azk.* #FUN-640012 mark
    DISPLAY BY NAME g_azk.azk01
    DISPLAY BY NAME g_azk.azk02
    DISPLAY BY NAME g_azk.azk03
    DISPLAY BY NAME g_azk.azk04
    DISPLAY BY NAME g_azk.azk041    
    DISPLAY BY NAME g_azk.azk051
    DISPLAY BY NAME g_azk.azk052
    ##FUN-640012...............end
    CALL i070_azk01('d')
    CALL cl_show_fld_cont()                   #No.FUN-550037 hmf
END FUNCTION
 
FUNCTION i070_u()
    IF s_shut(0) THEN RETURN END IF
    IF g_azk.azk01 IS NULL THEN CALL cl_err('',-400,0) RETURN END IF
    SELECT * INTO g_azk.* FROM azk_file
     WHERE azk01=g_azk.azk01 AND azk02=g_azk.azk02
    IF g_azk.azk02 = MDY(12,31,9999) THEN 
    CALL cl_err('','aoo-084',0)
       RETURN END IF
    MESSAGE ""
    CALL cl_opmsg('u')
    LET g_azk01_t = g_azk.azk01
    LET g_azk02_t = g_azk.azk02
    BEGIN WORK
 
    #-genero-------------------------------------------------------------
    #(1) If you have "?" inside above DECLARE SELECT FOR UPDATE SQL
    #(2) Then using syntax: "OPEN cursor USING variable"
    #For example, "OPEN a USING g_a_worid"
    #
    #* Remember to remove releated block of *.ora file, no more needed
    #--------------------------------------------------------------------
    #--Put variable into LOCK CURSOR
    OPEN i070_cl USING g_azk.azk01,g_azk.azk02
    #--Add exception check during OPEN CURSOR
    IF STATUS THEN
       CALL cl_err("OPEN i070_cl:", STATUS, 1)
       CLOSE i070_cl
       ROLLBACK WORK
       RETURN
    END IF
    FETCH i070_cl INTO g_azk.*     #對DB鎖定
    IF SQLCA.sqlcode THEN
        LET g_msg=g_azk.azk01 CLIPPED,'+',g_azk.azk02
        CALL cl_err(g_msg,SQLCA.sqlcode,0)
        RETURN
    END IF
    CALL i070_show()                          # 顯示最新資料
    WHILE TRUE
        CALL i070_i("u")                      # 欄位更改
        IF INT_FLAG THEN
            LET INT_FLAG = 0
            LET g_azk.*=g_azk_t.*
            CALL i070_show()
            CALL cl_err('',9001,0)
            EXIT WHILE
        END IF
        UPDATE azk_file SET azk_file.* = g_azk.*    # 更新DB
            WHERE azk01=g_azk.azk01 AND azk02=g_azk.azk02             # COLAUTH?
        IF SQLCA.sqlcode THEN
            LET g_msg=g_azk.azk01 CLIPPED,'+',g_azk.azk02
#           CALL cl_err(g_msg,SQLCA.sqlcode,0)   #No.FUN-660131
            CALL cl_err3("upd","azk_file",g_msg,"",SQLCA.sqlcode,"","",1)  #No.FUN-660131
            CONTINUE WHILE
        END IF
        CALL i070_mth()
        EXIT WHILE
    END WHILE
    CLOSE i070_cl
    COMMIT WORK
END FUNCTION
 
FUNCTION i070_r()
    DEFINE l_chr LIKE type_file.chr1          #No.FUN-680102 VARCHAR(1)
 
    IF s_shut(0) THEN RETURN END IF
    IF g_azk.azk01 IS NULL THEN CALL cl_err('',-400,0) RETURN END IF
    IF g_azk.azk02 = MDY(12,31,9999) THEN CALL cl_err('','aoo-084',0)
       RETURN END IF
    BEGIN WORK
 
    #-genero-------------------------------------------------------------
    #(1) If you have "?" inside above DECLARE SELECT FOR UPDATE SQL
    #(2) Then using syntax: "OPEN cursor USING variable"
    #For example, "OPEN a USING g_a_worid"
    #
    #* Remember to remove releated block of *.ora file, no more needed
    #--------------------------------------------------------------------
    #--Put variable into LOCK CURSOR
    OPEN i070_cl USING g_azk.azk01,g_azk.azk02
    #--Add exception check during OPEN CURSOR
    IF STATUS THEN
       CALL cl_err("OPEN i070_cl:", STATUS, 1)
       CLOSE i070_cl
       ROLLBACK WORK
       RETURN
    END IF
    FETCH i070_cl INTO g_azk.*
    IF SQLCA.sqlcode THEN
        LET g_msg=g_azk.azk01 CLIPPED,'+',g_azk.azk02
        CALL cl_err(g_msg,SQLCA.sqlcode,0)
        RETURN
    END IF
    CALL i070_show()
    IF cl_delete() THEN
        INITIALIZE g_doc.* TO NULL          #No.FUN-9B0098 10/02/24
        LET g_doc.column1 = "azk01"         #No.FUN-9B0098 10/02/24
        LET g_doc.value1 = g_azk.azk01      #No.FUN-9B0098 10/02/24
        LET g_doc.column2 = "azk02"         #No.FUN-9B0098 10/02/24
        LET g_doc.value2 = g_azk.azk02      #No.FUN-9B0098 10/02/24
        CALL cl_del_doc()                                         #No.FUN-9B0098 10/02/24
        DELETE FROM azk_file
            WHERE azk01=g_azk.azk01 AND azk02=g_azk.azk02
        IF SQLCA.SQLERRD[3]=0 THEN
            LET g_msg=g_azk.azk01 CLIPPED,'+',g_azk.azk02
#           CALL cl_err(g_msg,SQLCA.sqlcode,0)   #No.FUN-660131
            CALL cl_err3("del","azk_file",g_msg,"",SQLCA.sqlcode,"","",1)  #No.FUN-660131
        ELSE
           CALL i070_mth()   #TQC-720007
           CLEAR FORM
           OPEN i070_count
           #FUN-B50063-add-start--
           IF STATUS THEN
              CLOSE i070_cs
              CLOSE i070_count
              COMMIT WORK
              RETURN
           END IF
           #FUN-B50063-add-end-- 
           FETCH i070_count INTO g_row_count
           #FUN-B50063-add-start--
           IF STATUS OR (cl_null(g_row_count) OR  g_row_count = 0 ) THEN
              CLOSE i070_cs
              CLOSE i070_count
              COMMIT WORK
              RETURN
           END IF
           #FUN-B50063-add-end--
           DISPLAY g_row_count TO FORMONLY.cnt
           OPEN i070_cs
           IF g_curs_index = g_row_count + 1 THEN
              LET g_jump = g_row_count
              CALL i070_fetch('L')
           ELSE
              LET g_jump = g_curs_index
              LET g_no_ask = TRUE
              CALL i070_fetch('/')
           END IF
        END IF
    END IF
    CLOSE i070_cl
    COMMIT WORK
END FUNCTION
 
FUNCTION i070_copy()
    DEFINE
        l_n                 LIKE type_file.num5,          #No.FUN-680102 SMALLINT
        l_newno1,l_oldno1   LIKE azk_file.azk01,
        l_newno2,l_oldno2   LIKE azk_file.azk02
 
    IF s_shut(0) THEN RETURN END IF
    IF g_azk.azk01 IS NULL THEN
        CALL cl_err('',-400,0)
        RETURN
    END IF
    LET l_oldno1=g_azk.azk01
    LET l_oldno2=g_azk.azk02
 
     #-----No.MOD-480240-----
    LET g_before_input_done = FALSE
    CALL i070_set_entry("a")
    LET g_before_input_done = TRUE
    #-----END---------------
 
    INPUT l_newno1,l_newno2 FROM azk01,azk02
        AFTER FIELD azk01
          IF l_newno1 IS NOT NULL THEN
            LET g_azk.azk01=l_newno1
            CALL i070_azk01('a')
            IF g_chr='E' THEN
               CALL cl_err('','aoo-011',0)
               NEXT FIELD azk01
            END IF
          END IF
        AFTER FIELD azk02
          IF l_newno2 IS NOT NULL  THEN
            SELECT count(*) INTO g_cnt FROM azk_file
                WHERE azk01 = l_newno1 AND azk02 = l_newno2
            IF g_cnt > 0 THEN
                LET g_msg=l_newno1 CLIPPED,'+',l_newno2
                CALL cl_err(g_msg,-239,0)
                NEXT FIELD azk01
            END IF
          END IF
        ON ACTION controlp
            CASE
               WHEN INFIELD(azk01) #啟梗
#                 CALL q_azi(10,5,l_newno1) RETURNING l_newno1
#                 CALL FGL_DIALOG_SETBUFFER( l_newno1 )
    CALL cl_init_qry_var()
    LET g_qryparam.form = "q_azi"
    LET g_qryparam.default1 = l_newno1
    CALL cl_create_qry() RETURNING l_newno1
#    CALL FGL_DIALOG_SETBUFFER( l_newno1 )
                  DISPLAY BY NAME l_newno1
                  NEXT FIELD azk01
               OTHERWISE EXIT CASE
            END CASE
 
       ON IDLE g_idle_seconds
          CALL cl_on_idle()
          CONTINUE INPUT
 
      ON ACTION about         #MOD-4C0121
         CALL cl_about()      #MOD-4C0121
 
      ON ACTION help          #MOD-4C0121
         CALL cl_show_help()  #MOD-4C0121
 
      ON ACTION controlg      #MOD-4C0121
         CALL cl_cmdask()     #MOD-4C0121
 
 
    END INPUT
    IF INT_FLAG THEN
        LET INT_FLAG = 0
        DISPLAY BY NAME g_azk.azk01
        DISPLAY BY NAME g_azk.azk02
        RETURN
    END IF
    DROP TABLE x
    SELECT * FROM azk_file
        WHERE azk01=g_azk.azk01 AND azk02=g_azk.azk02
        INTO TEMP x
    UPDATE x
        SET azk01=l_newno1,   #資料鍵值-1
            azk02=l_newno2    #資料鍵值-2
    INSERT INTO azk_file
        SELECT * FROM x
    IF SQLCA.sqlcode THEN
        LET g_msg=g_azk.azk01 CLIPPED,'+',g_azk.azk02
#       CALL cl_err(g_msg,SQLCA.sqlcode,0)   #No.FUN-660131
        CALL cl_err3("ins","azk_file",g_msg,"",SQLCA.sqlcode,"","",1)  #No.FUN-660131
    ELSE
        MESSAGE 'ROW(',l_newno1,') O.K'
        SELECT azk_file.* INTO g_azk.* FROM azk_file
                       WHERE azk01 = l_newno1 AND azk02=l_newno2
        CALL i070_u()
        #SELECT azk_file.* INTO g_azk.* FROM azk_file             #FUN-C80046
        #               WHERE azk01 = l_oldno1 AND azk02=l_oldno2 #FUN-C80046
    END IF
    CALL i070_show()
END FUNCTION
 
FUNCTION i070_out()
    DEFINE
        l_i             LIKE type_file.num5,          #No.FUN-680102 SMALLINT
        l_name          LIKE type_file.chr20,                 # External(Disk) file name        #No.FUN-680102 VARCHAR(20)
        l_za05          LIKE type_file.chr1000,               #        #No.FUN-680102 VARCHAR(40)
        l_pmc03   LIKE pmc_file.pmc03,
        l_chr           LIKE type_file.chr1,          #No.FUN-680102 VARCHAR(1)
        sr              RECORD
                        azk01  LIKE azk_file.azk01,
                        azi02  LIKE azi_file.azi02,
                        azk02  LIKE azk_file.azk02,
                        azk03  LIKE azk_file.azk03,
                        azk04  LIKE azk_file.azk04,
                        azk041 LIKE azk_file.azk041,
                        azk051 LIKE azk_file.azk051,
                        azk052 LIKE azk_file.azk052 
                        #azk05  LIKE azk_file.azk05 #FUN-640012 mark
                        END RECORD
 DEFINE t_azi07 LIKE azi_file.azi07                 #No.FUN-760083  
 
    IF cl_null(g_wc) THEN
       LET g_wc=" azk01='",g_azk.azk01,"' AND"," azk02='",g_azk.azk02,"'"
    END IF
 
    IF g_wc IS NULL THEN
        CALL cl_err('','9057',0)
        RETURN
    END IF
    LET g_str=''                                  #No.FUN-760083
    CALL cl_del_data(l_table)                     #No.FUN-760083
    SELECT zz05 INTO g_zz05 FROM zz_file WHERE zz01=g_prog    #No.FUN-760083
    #CALL cl_wait()                               #No.FUN-760083
    #CALL cl_outnam('aooi070') RETURNING l_name   #No.FUN-760083
    SELECT zo02 INTO g_company FROM zo_file WHERE zo01 = g_lang
    LET g_sql="SELECT azk01,azi02,azk02,azk03,azk04,azk041,azk051,azk052",  #,azk05  #FUN-640012 mark
              "  FROM azk_file LEFT OUTER JOIN azi_file ON azi01 = azk01",      # 組合出 SQL 指令
              " WHERE ",g_wc CLIPPED
    PREPARE i070_p1 FROM g_sql                # RUNTIME 編譯
    DECLARE i070_co                         # SCROLL CURSOR
         CURSOR FOR i070_p1
 
    #START REPORT i070_rep TO l_name           #No.FUN-760083
 
    FOREACH i070_co INTO sr.*
        IF SQLCA.sqlcode THEN
            CALL cl_err('foreach:',SQLCA.sqlcode,1)   
            EXIT FOREACH
        END IF
 
#No.FUN-760083  --begin--
        SELECT azi07 INTO t_azi07 FROM azi_file WHERE azi01=sr.azk01                                                            
            IF SQLCA.sqlcode OR cl_null(t_azi07) THEN                                                                               
               LET t_azi07=0                                                                                                        
            END IF                                    
        EXECUTE insert_prep USING sr.azk01,sr.azi02,sr.azk02,sr.azk03,sr.azk04,
                                  sr.azk041,sr.azk051,sr.azk052,t_azi07
#No.FUN-760083  --end--
 
        #OUTPUT TO REPORT i070_rep(sr.*)       #No.FUN-760083
    END FOREACH
    
    #FINISH REPORT i070_rep                    #No.FUN-760083
 
    CLOSE i070_co
    ERROR ""
    #CALL cl_prt(l_name,' ','1',g_len)         #No.FUN-760083  
    LET g_sql="SELECT * FROM ",g_cr_db_str CLIPPED,l_table CLIPPED   #No.FUN-760083 
    IF g_zz05='Y' THEN                                                      #No.FUN-760083 
       CALL cl_wcchp(g_wc,'azk01,azk02,azk04,azk03,azk041,azk051,azk052')   #No.FUN-760083  
       RETURNING  g_wc                                                      #No.FUN-760083 
    END IF                                                                  #No.FUN-760083 
    LET g_str=g_wc                                                          #No.FUN-760083 
    CALL cl_prt_cs3("aooi070","aooi070",g_sql,g_str)                        #No.FUN-760083  
END FUNCTION
 
#No.FUN-760083
{
REPORT i070_rep(sr)
    DEFINE
        l_trailer_sw    LIKE type_file.chr1,           #No.FUN-680102CHAR(1), 
        l_chr           LIKE type_file.chr1,          #No.FUN-680102 VARCHAR(1)
        sr              RECORD
                        azk01  LIKE azk_file.azk01,
                        azi02  LIKE azi_file.azi02,
                        azk02  LIKE azk_file.azk02,
                        azk03  LIKE azk_file.azk03,
                        azk04  LIKE azk_file.azk04,
                        azk041 LIKE azk_file.azk041,
                        azk051 LIKE azk_file.azk051,
                        azk052 LIKE azk_file.azk052 
                        #azk05  LIKE azk_file.azk05  #FUN-640012 mark
                        END RECORD
   OUTPUT
       TOP MARGIN g_top_margin
       LEFT MARGIN g_left_margin
       BOTTOM MARGIN g_bottom_margin
       PAGE LENGTH g_page_line   #No.MOD-580242
 
    ORDER BY sr.azk01,sr.azk02
    FORMAT
        PAGE HEADER
            PRINT COLUMN ((g_len-FGL_WIDTH(g_company CLIPPED))/2)+1,g_company CLIPPED
            PRINT COLUMN ((g_len-FGL_WIDTH(g_x[1]))/2)+1,g_x[1]
            LET g_pageno=g_pageno+1
            LET pageno_total=PAGENO USING '<<<',"/pageno"
            PRINT g_head CLIPPED,pageno_total
            PRINT g_dash
            PRINT COLUMN (g_c[34]+20),g_x[9] CLIPPED,
                  COLUMN (g_c[37]+14),g_x[10]
            PRINT COLUMN g_c[34],g_dash2[1,g_w[34]+g_w[35]+g_w[36]+2],
                  COLUMN g_c[37],g_dash2[1,g_w[37]+g_w[38]+1]  #+g_w[39]  #FUN-640012 mark
            PRINT g_x[31],g_x[32],g_x[33],g_x[34],
                  g_x[35],g_x[36],g_x[37],g_x[38]
                  #g_x[39] CLIPPED  #FUN-640012 mark
            PRINT g_dash1
            LET l_trailer_sw = 'y'
        ON EVERY ROW
            SELECT azi07 INTO t_azi07 FROM azi_file WHERE azi01=sr.azk01
            IF SQLCA.sqlcode OR cl_null(t_azi07) THEN
               LET t_azi07=0
            END IF
            PRINT COLUMN g_c[31],sr.azk01,
                  COLUMN g_c[32],sr.azi02,
                  COLUMN g_c[33],sr.azk02,
                  COLUMN g_c[34],cl_numfor(sr.azk03  ,34,t_azi07),
                  COLUMN g_c[35],cl_numfor(sr.azk04  ,35,t_azi07),
                  COLUMN g_c[36],cl_numfor(sr.azk041 ,36,t_azi07),
                  COLUMN g_c[37],cl_numfor(sr.azk051 ,37,t_azi07),
                  COLUMN g_c[38],cl_numfor(sr.azk052 ,38,t_azi07) 
                  #COLUMN g_c[39],cl_numfor(sr.azk05  ,39,t_azi07)  #FUN-640012 mark
        ON LAST ROW
            IF g_zz05 = 'Y'          # 80:70,140,210      132:120,240
               THEN PRINT g_dash
#NO.TQC-630166 start--
#                    IF g_wc[001,080] > ' ' THEN
#		       PRINT g_x[8] CLIPPED,g_wc[001,070] CLIPPED END IF
#                    IF g_wc[071,140] > ' ' THEN
#		       PRINT COLUMN 10,     g_wc[071,140] CLIPPED END IF
#                    IF g_wc[141,210] > ' ' THEN
#		       PRINT COLUMN 10,     g_wc[141,210] CLIPPED END IF
                     CALL cl_prt_pos_wc(g_wc)
#NO.TQC-630166 end--
            END IF
            PRINT g_dash
            PRINT g_x[4],g_x[5] CLIPPED, COLUMN (g_len-9), g_x[7] CLIPPED
            LET l_trailer_sw = 'n'
        PAGE TRAILER
            IF l_trailer_sw = 'y' THEN
                PRINT g_dash
                PRINT g_x[4],g_x[5] CLIPPED, COLUMN (g_len-9), g_x[6] CLIPPED
            ELSE
                SKIP 2 LINE
            END IF
END REPORT
}
#No.FUN-760083
 
FUNCTION i070_set_entry(p_cmd)
   DEFINE   p_cmd     LIKE type_file.chr1          #No.FUN-680102 VARCHAR(1)
 
     IF p_cmd = 'a'  AND (NOT g_before_input_done) THEN
         CALL cl_set_comp_entry("azk01,azk02",TRUE)
     END IF
 
END FUNCTION
 
FUNCTION i070_set_no_entry(p_cmd)
   DEFINE   p_cmd     LIKE type_file.chr1          #No.FUN-680102 VARCHAR(1)
 
   IF p_cmd = 'u' AND g_chkey = 'N' THEN
      CALL cl_set_comp_entry("azk01,azk02",FALSE)
   END IF
 
END FUNCTION
 
#No.FUN-740074 --start--
FUNCTION i070_get_java_exrate()
   DEFINE l_url        STRING
   DEFINE l_num        STRING
   DEFINE l_msg        STRING
   DEFINE l_filepath   STRING
   DEFINE l_ch         base.Channel
   DEFINE l_st         base.StringTokenizer
   DEFINE l_sb         base.StringBuffer
   DEFINE l_buf        STRING
   DEFINE l_buf2       STRING
   DEFINE l_row        LIKE type_file.num10
   DEFINE l_col        LIKE type_file.num10
   DEFINE l_str        STRING
   DEFINE l_date       LIKE azk_file.azk02
   DEFINE l_dateSpos   LIKE type_file.num10
   DEFINE l_dateEpos   LIKE type_file.num10
   DEFINE l_i          LIKE type_file.num10
   DEFINE l_type       LIKE type_file.num5
   DEFINE l_getBuyCol  LIKE type_file.num10 
   DEFINE l_getSaleCol LIKE type_file.num10 
   DEFINE l_azk041     LIKE azk_file.azk041
   DEFINE l_cnt        LIKE type_file.num10 #No.TQC-750176
 
   DEFINE l_azk DYNAMIC ARRAY OF RECORD
      azk01 LIKE azk_file.azk01,
      azk03 LIKE azk_file.azk03,
      azk04 LIKE azk_file.azk04,
      azk051 LIKE azk_file.azk051,   #MOD-850007
      azk052 LIKE azk_file.azk052    #MOD-850007
   END RECORD
 
   LET l_type = 2
   
   IF g_bgjob='N' OR cl_null(g_bgjob) THEN
      OPEN WINDOW cl_prtmsg_w WITH FORM "aoo/42f/aooi0701"
         ATTRIBUTE(STYLE="lib")
         
      CALL cl_ui_locale("aooi0701")
         
      INPUT l_type WITHOUT DEFAULTS FROM FORMONLY.in_ch
         AFTER FIELD FORMONLY.in_ch
            IF l_type != 1 AND l_type != 2 THEN
               NEXT FIELD FORMONLY.in_ch
            END IF
         ON ACTION CANCEL
            LET l_type = 0
            EXIT INPUT   
         ON IDLE g_idle_seconds
            CALL cl_on_idle()
            CONTINUE INPUT
      END INPUT
      
      IF (INT_FLAG) THEN
         LET INT_FLAG = FALSE
         LET l_type = 0
      END IF
      
      CLOSE WINDOW cl_prtmsg_w
   ELSE      
      LET l_type = g_argv2
   END IF
   
   CASE l_type
      WHEN 1
         LET l_getBuyCol = 3
         LET l_getSaleCol = 13
      WHEN 2
         LET l_getBuyCol = 4
         LET l_getSaleCol = 14
      OTHERWISE
         DISPLAY "Stop l_type: "||l_type
         LET g_flag = 'N' #CHI-C20056 add
         RETURN
   END CASE
 
   #call java code to get the text file
   LET l_url = FGL_GETENV("EXRATEURL")
   CALL s_jget_exrate(l_url) RETURNING l_num, l_msg
   #DISPLAY "code: ",l_num,ASCII 10,"msg: ",l_msg
   
   #if return code != 0 or return file == null then return
   IF l_num = 0 THEN
      IF cl_null(l_msg) THEN
         IF g_bgjob='N' OR cl_null(g_bgjob) THEN
            LET l_str = cl_getmsg("aoo-303",g_lang)
            LET l_str = l_str,ASCII 10,"Error: Filename is null."
            CALL cl_msgany(0,0,l_str)
         ELSE            
            DISPLAY "Error: Filename is null."
         END IF
         LET g_flag = 'N' #CHI-C20056 add
         RETURN
      END IF
   ELSE
      IF g_bgjob='N' OR cl_null(g_bgjob) THEN
         LET l_str = cl_getmsg("aoo-303",g_lang)
         LET l_str = l_str,ASCII 10,"Error: "||l_num||" "||l_msg
         CALL cl_msgany(0,0,l_str)
      ELSE
         DISPLAY "Error: "||l_num||" "||l_msg
      END IF
      LET g_flag = 'N' #CHI-C20056 add
      RETURN
   END IF
   
   #get date from the file name
   LET l_filepath = l_msg
   #No.FUN-960067 --start--
   #LET l_dateSpos = l_filepath.getIndexOf("-",1)
   #LET l_dateEpos = l_filepath.getIndexOf(".",1)
   #LET l_date = l_filepath.subString(l_dateSpos+1,l_dateEpos-1)
   LET l_date = g_today USING "yyyymmdd"
   #No.FUN-960067 --end--
   
   #check the exrate is exists in db
   SELECT COUNT(*) INTO l_row FROM azk_file WHERE azk02 = l_date
   IF SQLCA.SQLCODE THEN
      CALL cl_err3("sel","azk_file",l_date,"",SQLCA.sqlcode,"","",1)
   END IF
   DISPLAY l_row 
   IF l_row > 0 THEN
      IF g_bgjob='N' OR cl_null(g_bgjob) THEN
         IF NOT cl_confirm("aoo-301") THEN
            LET g_flag = 'N' #CHI-C20056 add
            RETURN
         END IF
      ELSE
         IF NOT g_argv3 MATCHES '[Yy]' THEN
            LET g_flag = 'N' #CHI-C20056 add
            RETURN
         END IF
      END IF
   END IF
   
   #read the text file
   LET l_ch = base.Channel.create()
   CALL l_ch.setDelimiter("")
   CALL l_ch.openFile(l_filepath,"r")
   IF STATUS == 0 THEN
      LET l_col = 0
      LET l_row = 0
      CALL l_ch.readLine() RETURNING l_buf
      #IF l_buf IS NOT NULL THEN #FUN-960178
      IF NOT l_ch.isEof() THEN   #FUN-960178
         WHILE TRUE
            CALL l_ch.readLine() RETURNING l_buf
            #FUN-960178 --start--
            IF l_ch.isEof() THEN EXIT WHILE END IF
            #IF l_buf IS NULL THEN
            #   EXIT WHILE
            #ELSE
            #FUN-960178 --end--
            
            LET l_row = l_row + 1
            LET l_st = base.StringTokenizer.create(l_buf," \t")
            LET l_col = 0
            CALL l_azk.appendElement()
            WHILE l_st.hasMoreTokens()
               LET l_col = l_col + 1
               LET l_buf2 = l_st.nextToken()
               CASE l_col
                 WHEN 1
                    LET l_azk[l_row].azk01 = l_buf2
                 WHEN l_getBuyCol
                    LET l_azk[l_row].azk03 = l_buf2
                 WHEN l_getSaleCol
                    LET l_azk[l_row].azk04 = l_buf2
               END CASE
            END WHILE
            #END IF #FUN-960178
         END WHILE
      END IF 
   END IF
   CALL l_ch.close()
   
   #store to db
   BEGIN WORK
   #DELETE FROM azk_file WHERE azk02=l_date   #MOD-850007
   FOR l_i = 1 TO l_row
      #-----MOD-850007---------
      SELECT azk051,azk052 INTO l_azk[l_i].azk051,l_azk[l_i].azk052
        FROM azk_file
       WHERE azk02=l_date AND azk01=l_azk[l_i].azk01 
      #CHI-C20056 mark start -----
      ##FUN-950087 -------------------add start-------------
      #IF g_aza.aza17 != l_azk[l_i].azk01 THEN
      #   IF cl_null(l_azk[l_i].azk051) OR cl_null(l_azk[l_i].azk052) OR l_azk[l_i].azk051 = 0 OR l_azk[l_i].azk052 = 0 THEN
      #      LET g_sql = " SELECT azk051,azk052 FROM azk_file ",
      #                  "  WHERE azk01 = '",l_azk[l_i].azk01,"'",
      #                  "    AND azk051 > 0 AND azk052 > 0 ",
      #                  "  ORDER BY azk02 DESC "
      #      PREPARE i070_pre02 FROM g_sql
      #      DECLARE i070_curs02 CURSOR FOR i070_pre02

      #      LET l_azk[l_i].azk051=0
      #      LET l_azk[l_i].azk052=0
      #      FOREACH i070_curs02 INTO l_azk[l_i].azk051,l_azk[l_i].azk052
      #        IF SQLCA.sqlcode THEN
      #           CALL cl_err('foreach:',SQLCA.sqlcode,1)
      #           EXIT FOREACH
      #        ELSE
      #           EXIT FOREACH
      #        END IF
      #      END FOREACH
      #   END IF
      #ELSE
      ##FUN-950087-------------------add end-------------- 
      #CHI-C20056 mark end    -----
         IF cl_null(l_azk[l_i].azk051) THEN LET l_azk[l_i].azk051=0 END IF
         IF cl_null(l_azk[l_i].azk052) THEN LET l_azk[l_i].azk052=0 END IF
      #END IF            #FUN-950087 #CHI-C20056 mark 
      DELETE FROM azk_file WHERE azk02=l_date AND azk01=l_azk[l_i].azk01
      #-----END MOD-850007-----
      LET l_azk041 = (l_azk[l_i].azk03 + l_azk[l_i].azk04)/2
      #No.TQC-750176 --start--
      #SELECT azi01 FROM azi_file WHERE azi01 = l_azk[l_i].azk01 
      #AND aziacti='Y'
      #IF SQLCA.SQLCODE = NOTFOUND THEN
      #   CONTINUE FOR
      #END IF
      SELECT COUNT(*) INTO l_cnt FROM azi_file 
      WHERE azi01 = l_azk[l_i].azk01 AND aziacti='Y'
      IF l_cnt < 1 THEN
          CONTINUE FOR
      END IF

      INSERT INTO azk_file (azk01,azk02,azk03,azk04,azk041,azk05,azk051,azk052)
      VALUES (l_azk[l_i].azk01,l_date,l_azk[l_i].azk03,l_azk[l_i].azk04,
      l_azk041,l_azk041,l_azk[l_i].azk051,l_azk[l_i].azk052)   #MOD-850007
      
      IF SQLCA.SQLCODE THEN
         EXIT FOR
      END IF
   END FOR
         
   IF SQLCA.SQLCODE = 0 THEN
      COMMIT WORK
      #CHI-C20056 mark start -----
      #IF g_bgjob='N' OR cl_null(g_bgjob) THEN
      #   LET l_str = cl_getmsg("aoo-302",g_lang)
      #   CALL cl_msgany(0,0,l_str)
      #END IF
      #CHI-C20056 mark end   -----
   ELSE
    #  ROLLBACK WORK    #FUN-B80035   MARK
      IF g_bgjob='N' OR cl_null(g_bgjob) THEN
         LET g_msg = l_azk[l_i].azk01 CLIPPED,"+",l_date
         CALL cl_err3("ins","azk_file",g_msg,"",SQLCA.sqlcode,"","",1)
      END IF
      ROLLBACK WORK     #FUN-B80035   ADD
   END IF
   
   FOR l_i = 1 TO l_row
      LET g_azk.azk01 =l_azk[l_i].azk01
      LET g_azk.azk02 =l_date
#MOD-B90162 -- begin --
      SELECT COUNT(*) INTO l_cnt FROM azi_file
      WHERE azi01 = l_azk[l_i].azk01 AND aziacti='Y'
      IF l_cnt < 1 THEN
          CONTINUE FOR
      END IF
#MOD-B90162 -- end --
      CALL i070_mth()
   END FOR
END FUNCTION

#No.FUN-B10021 --start--
FUNCTION i070_get_java_excustomsrate()
   DEFINE l_url        STRING
   DEFINE l_num        STRING
   DEFINE l_msg        STRING
   DEFINE l_filepath   STRING
   DEFINE l_ch         base.Channel
   DEFINE l_st         base.StringTokenizer
   DEFINE l_sb         base.StringBuffer
   DEFINE l_buf        STRING
   DEFINE l_buf2       STRING
   DEFINE l_row        LIKE type_file.num10
   DEFINE l_col        LIKE type_file.num10
   DEFINE l_str        STRING
   DEFINE l_date       LIKE azk_file.azk02
   DEFINE l_dateSpos   LIKE type_file.num10
   DEFINE l_dateEpos   LIKE type_file.num10
   DEFINE l_i          LIKE type_file.num10
   DEFINE l_type       LIKE type_file.num5
   DEFINE l_getBuyCol  LIKE type_file.num10 
   DEFINE l_getSaleCol LIKE type_file.num10 
   DEFINE l_azk041     LIKE azk_file.azk041
   DEFINE l_cnt        LIKE type_file.num10 #No.TQC-750176
   DEFINE l_date_d     LIKE type_file.num10  #CHI-B60062 add
   DEFINE l_date_2     LIKE azk_file.azk02   #CHI-B60062 add
   DEFINE l_azk051     LIKE azk_file.azk051  #CHI-B60062 add
   DEFINE l_azk052     LIKE azk_file.azk052  #CHI-B60062 add
   DEFINE l_cn         LIKE type_file.num10  #CHI-B60062 add
   DEFINE l_date_s     LIKE type_file.dat    #CHI-C20056 add
   DEFINE l_date_e     LIKE type_file.dat    #CHI-C20056 add

   DEFINE l_azk DYNAMIC ARRAY OF RECORD
      azk01 LIKE azk_file.azk01, --幣別
      azk03 LIKE azk_file.azk03, --買入
      azk04 LIKE azk_file.azk04, --賣出
      azk051 LIKE azk_file.azk051,   #MOD-850007 海關買入
      azk052 LIKE azk_file.azk052,    #MOD-850007 海關賣出
      azk011 LIKE type_file.num5,  #CHI-D20022
      azk012 LIKE type_file.num5,  #CHI-D20022
      azk013 LIKE type_file.num5   #CHI-D20022
   END RECORD
   #CHI-D20022---begin
   DEFINE l_filepath1  STRING 
   DEFINE l_ch1        base.Channel  
   DEFINE l_his DYNAMIC ARRAY OF RECORD
      his01 LIKE azk_file.azk01,         #幣別
      his02 LIKE type_file.num5,         #年度
      his03 LIKE type_file.num5,         #月
      his04 LIKE type_file.num5,         #旬
      his05 LIKE azk_file.azk051,        #海關買入匯率
      his06 LIKE azk_file.azk052         #海關賣出匯率
   END RECORD
   DEFINE l_his04 LIKE type_file.num5
   DEFINE l_his05 LIKE type_file.chr10
   DEFINE l_his06 LIKE type_file.chr10
   DEFINE l_date_y     LIKE type_file.num5
   DEFINE l_date_m     LIKE type_file.num5 
   ##CHI-D20022---end
   #190123 kerwin
   DEFINE k_azk01 LIKE azk_file.azk01,
          k_year LIKE type_file.num5,
          k_month LIKE type_file.num5,
          k_tenday LIKE type_file.num5,
          k_azk051 LIKE azk_file.azk051,
          k_azk052 LIKE azk_file.azk052

#190123 kerwin 
{   
   #java呼叫海關匯率回傳訊息數字及文字檔  
   CALL s_jget_excustrate(l_url) RETURNING l_num, l_msg 
   
   IF l_num = 0 THEN
      IF cl_null(l_msg) THEN
         IF g_bgjob='N' OR cl_null(g_bgjob) THEN
            LET l_str = cl_getmsg("aoo-303",g_lang)
            LET l_str = l_str,ASCII 10,"Error: Filename is null."
            CALL cl_msgany(0,0,l_str)
         ELSE            
            DISPLAY "Error: Filename is null."
         END IF
         RETURN
      END IF
   ELSE
      IF g_bgjob='N' OR cl_null(g_bgjob) THEN
         LET l_str = cl_getmsg("aoo-303",g_lang)
         LET l_str = l_str,ASCII 10,"Error: "||l_num||" "||l_msg
         CALL cl_msgany(0,0,l_str)
      ELSE
         DISPLAY "Error: "||l_num||" "||l_msg
      END IF
      RETURN
   END IF
   
   #get date from the file name
   #CHI-D20022---begin
   #LET l_filepath = l_msg  
   LET l_filepath = l_msg.subString(1,l_msg.getindexof(',',1)-1) 
   LET l_filepath1 = l_msg.subString(l_msg.getIndexOf(',',1)+1,l_msg.getLength()) 
   #CHI-D20022---end
   #LET l_filepath = l_msg  #MOD-D40190
}
#190123 kerwin mark  
   LET l_date = g_today USING "yyyymmdd"

   SELECT COUNT(*) INTO l_row FROM azk_file WHERE azk02 = l_date
   IF SQLCA.SQLCODE THEN
      CALL cl_err3("sel","azk_file",l_date,"",SQLCA.sqlcode,"","",1)
   END IF

   #MOD-B40107---mark---start---
   #IF l_row > 0 THEN
   #   IF g_bgjob='N' OR cl_null(g_bgjob) THEN
   #      IF NOT cl_confirm("aoo-301") THEN
   #         RETURN
   #      END IF
   #   ELSE
   #      IF NOT g_argv3 MATCHES '[Yy]' THEN
   #         RETURN
   #      END IF
   #   END IF
   #END IF
   #MOD-B40107---mark---end---
   #CHI-D20022---begin
   LET l_date_y = g_today USING "yyyy"
   LET l_date_y = l_date_y - 1911
   LET l_date_m = g_today USING "mm"
   LET l_date_d = g_today USING "dd"
   IF l_date_d >= 1 AND l_date_d <= 10 THEN
      LET l_his04 = 1
   END IF 
   IF l_date_d >= 11 AND l_date_d <= 20 THEN
      LET l_his04 = 2
   END IF 
   IF l_date_d >= 21 AND l_date_d <= 31 THEN
      LET l_his04 = 3
   END IF 
   #read the text file
   LET l_ch1 = base.Channel.create()
#190123 kerwin
   RUN "wget -q –no-cache -O /u1/out/temp_aooi070.out http://portal.sw.nat.gov.tw/APGQ/GC331!downLoad?formBean.downLoadFile=CURRENT_TXT "    #&& sed -e '1d' /u1/out/temp_aooi070.out"
   RUN "iconv -f BIG-5 -t UTF-8 /u1/out/temp_aooi070.out > /u1/out/aooi070.out"
   let l_filepath1 = "/u1/out/aooi070.out"
   let l_row = 0
   CALL l_ch1.setDelimiter("	")
   call l_ch1.openPipe("cat /u1/out/aooi070.out","r")
    WHILE l_ch1.read([k_azk01,k_year,k_month,k_tenday,k_azk051,k_azk052])
        if l_row > 0 then
          let l_azk[l_row].azk01  = k_azk01
          let l_azk[l_row].azk011 = k_year
          let l_azk[l_row].azk012 = k_month
          let l_azk[l_row].azk013 = k_tenday
          let l_azk[l_row].azk051 = k_azk051
          let l_azk[l_row].azk052 = k_azk052
        end if
          LET l_row = l_row + 1
    END WHILE
   CALL l_ch1.close()
#190123 kerwin mark
{
#   CALL l_ch1.openFile(l_filepath1,"r")
#
   IF STATUS == 0 THEN
      #LET l_col = 0
      LET l_row = 0
      let l_buf = l_ch1.readLine()
#      CALL l_ch1.readLine() RETURNING l_buf
      IF l_buf IS NOT NULL THEN
         WHILE TRUE
            CALL l_ch1.readLine() RETURNING l_buf
            IF l_buf IS NULL THEN
               EXIT WHILE
            ELSE
               LET l_st = base.StringTokenizer.create(l_buf," \t")
               #LET l_col = 0
               #CALL l_azk.appendElement()
               #WHILE l_st.hasMoreTokens()
                  #LET l_col = l_col + 1
                  LET l_buf2 = l_st.nextToken()
                  IF l_buf2.subString(4,6) <> l_date_y THEN CONTINUE WHILE END IF 
                  IF l_buf2.subString(7,8) <> l_date_m THEN CONTINUE WHILE END IF 
                  IF l_buf2.subString(9,9) <> l_his04 THEN CONTINUE WHILE END IF 
                  LET l_row = l_row + 1
                  LET l_his[l_row].his01 = l_buf2.subString(1,3)
                  LET l_his[l_row].his02 = l_buf2.subString(4,6)
                  LET l_his[l_row].his03 = l_buf2.subString(7,8)
                  LET l_his[l_row].his04 = l_buf2.subString(9,9)
                  LET l_his06 = l_buf2.subString(10,12),".",l_buf2.subString(13,17)
                  LET l_his[l_row].his06 = l_his06
                  LET l_his05 = l_buf2.subString(18,20),".",l_buf2.subString(21,25)
                  LET l_his[l_row].his05 = l_his05
               #END WHILE
            END IF
         END WHILE
      END IF
   END IF
   CALL l_ch1.close()
   #CHI-D20022---end

   #read the text file
   LET l_ch = base.Channel.create()
   CALL l_ch.setDelimiter("")
   CALL l_ch.openFile(l_filepath,"r")
   IF STATUS == 0 THEN
      LET l_col = 0
      LET l_row = 0
      CALL l_ch.readLine() RETURNING l_buf
      IF l_buf IS NOT NULL THEN
         WHILE TRUE
            CALL l_ch.readLine() RETURNING l_buf
            IF l_buf IS NULL THEN
               EXIT WHILE
            ELSE
               LET l_row = l_row + 1
               LET l_st = base.StringTokenizer.create(l_buf," \t")
               LET l_col = 0
               CALL l_azk.appendElement()
               WHILE l_st.hasMoreTokens()
                  LET l_col = l_col + 1
                  LET l_buf2 = l_st.nextToken()
                  #DISPLAY "l_buf2=",l_buf2
                  CASE l_col 
                     WHEN 1  -- 幣別
                        LET l_azk[l_row].azk01 = l_buf2
                        #DISPLAY "l_buf2=",l_buf2
                     #CHI-D20022---begin
                     WHEN 2  -- 年
                        LET l_azk[l_row].azk011 = l_buf2
                     WHEN 3  -- 月
                        LET l_azk[l_row].azk012 = l_buf2
                     WHEN 4  -- 旬
                        LET l_azk[l_row].azk013 = l_buf2
                     #CHI-D20022---end
		             WHEN 5 -- 買進
                        LET l_azk[l_row].azk051 = l_buf2
                     WHEN 6 -- 賣出
                        LET l_azk[l_row].azk052 = l_buf2
                  END CASE
               END WHILE
               #CHI-D20022---begin
               IF l_azk[l_row].azk011 <> l_date_y OR l_azk[l_row].azk012 <> l_date_m OR l_azk[l_row].azk013 <> l_his04 THEN 
                  FOR l_i = 1 TO l_his.getLength()
                     IF l_azk[l_row].azk01 = l_his[l_i].his01 THEN
                        LET l_azk[l_row].azk051 = l_his[l_i].his05
                        LET l_azk[l_row].azk052 = l_his[l_i].his06
                        EXIT FOR 
                     END IF 
                  END FOR 
               END IF 
               #CHI-D20022---end
            END IF
         END WHILE
      END IF
   END IF
   CALL l_ch.close()
}---------------------------------------------------------------------------------      
   #store to db
   BEGIN WORK

   CALL s_showmsg_init() #CHI-C20056 add
   FOR l_i = 1 TO l_row --筆數
      SELECT azk03,azk04 INTO l_azk[l_i].azk03,l_azk[l_i].azk04 -- 買入 賣出
        FROM azk_file -- 幣別每日匯率檔
       WHERE azk02=l_date AND azk01=l_azk[l_i].azk01 --幣別跟日期做條件

      IF cl_null(l_azk[l_i].azk051) THEN LET l_azk[l_i].azk051=0 END IF --海關買入
      IF cl_null(l_azk[l_i].azk052) THEN LET l_azk[l_i].azk052=0 END IF --海關賣出

      DELETE FROM azk_file WHERE azk02=l_date AND azk01=l_azk[l_i].azk01

      #-----END MOD-1000117-----
      LET l_azk041 = (l_azk[l_i].azk03 + l_azk[l_i].azk04)/2 -- 銀行中價匯率

      SELECT COUNT(*) INTO l_cnt FROM azi_file -- 判斷是否有這個幣別 幣別檔(table)
      WHERE azi01 = l_azk[l_i].azk01 AND aziacti='Y'
      IF l_cnt < 1 THEN
          CONTINUE FOR
      END IF

      #CHI-B60062 --- modify --- start ---
      LET l_date_d = g_today USING "dd"
      IF l_date_d >= 1 AND l_date_d <= 10 THEN
         #CHI-C20056 add start -----
         IF l_date_d >= 1 AND l_date_d <= 4 THEN
            LET l_azk051 = l_azk[l_i].azk051
            LET l_azk052 = l_azk[l_i].azk052
         ELSE
            LET l_date_s = g_today - l_date_d + 1
            LET l_date_e = g_today - l_date_d + 4
            CALL i070_date_set(l_azk[l_i].azk01,l_date_s,l_date_e) RETURNING l_azk051,l_azk052
         END IF
         #CHI-C20056 add end   -----
         #LET l_date_2 = g_today - l_date_d + 1 #CHI-C20056 mark
      ELSE
         IF l_date_d >= 11 AND l_date_d <= 20 THEN
             #CHI-C20056 add start -----
             IF l_date_d >= 11 AND l_date_d <= 14 THEN
                LET l_azk051 = l_azk[l_i].azk051
                LET l_azk052 = l_azk[l_i].azk052
             ELSE
                LET l_date_s = g_today - l_date_d + 11
                LET l_date_e = g_today - l_date_d + 14
                CALL i070_date_set(l_azk[l_i].azk01,l_date_s,l_date_e) RETURNING l_azk051,l_azk052
             END IF
             #CHI-C20056 add end   -----
             #LET l_date_2 = g_today - l_date_d + 11 #CHI-C20056 mark
         ELSE
             IF l_date_d >= 21 AND l_date_d <= 31 THEN
                #CHI-C20056 add start -----
                IF l_date_d >= 21 AND l_date_d <= 24 THEN
                   LET l_azk051 = l_azk[l_i].azk051
                   LET l_azk052 = l_azk[l_i].azk052
                ELSE
                   #LET l_date_s = g_today - l_date_d + 11 #MOD-C90236 mark
                   #LET l_date_e = g_today - l_date_d + 14 #MOD-C90236 mark
                   LET l_date_s = g_today - l_date_d + 21  #MOD-C90236 add
                   LET l_date_e = g_today - l_date_d + 24  #MOD-C90236 add
                   CALL i070_date_set(l_azk[l_i].azk01,l_date_s,l_date_e) RETURNING l_azk051,l_azk052
                END IF
                #CHI-C20056 add end   -----
                #LET l_date_2 = g_today - l_date_d + 21 #CHI-C20056 mark
             END IF
         END IF
      END IF

      #CHI-C20056 mark start -----
      #LET l_cn = 0

      #SELECT COUNT(*) INTO l_cn FROM azk_file
      # WHERE azk01 = l_azk[l_i].azk01
      #   AND azk02 = l_date_2

      #IF l_cn > 0 THEN
      #   SELECT azk051,azk052 INTO l_azk051,l_azk052 FROM azk_file
      #    WHERE azk01 = l_azk[l_i].azk01
      #      AND azk02 = l_date_2
      #CHI-C20056 mark end   -----
      #MOD-D50003---begin
      IF cl_null(l_azk051) OR l_azk051 = 0 THEN 
         LET l_azk051 = l_azk[l_i].azk051
      END IF 
      IF cl_null(l_azk052) OR l_azk052 = 0 THEN 
         LET l_azk052 = l_azk[l_i].azk052 
      END IF
      #MOD-D50003---end
         INSERT INTO azk_file (azk01,azk02,azk03,azk04,azk041,azk05,azk051,azk052)
         VALUES (l_azk[l_i].azk01,l_date,l_azk[l_i].azk03,l_azk[l_i].azk04,
         l_azk041,l_azk041,l_azk051,l_azk052)
      #CHI-C20056 mark start -----
      #ELSE
      #   #CHI-C20056 add start -----
      #   CALL s_errmsg('',l_azk[l_i].azk01,'','aoo1006',1)
      #   LET l_err_cn = l_err_cn + 1 
      #CHI-C20056 mark start -----
         #CHI-C20056 add end   -----
         #CHI-C20056 mark start -----
         #INSERT INTO azk_file (azk01,azk02,azk03,azk04,azk041,azk05,azk051,azk052)
         #VALUES (l_azk[l_i].azk01,l_date,l_azk[l_i].azk03,l_azk[l_i].azk04,
         #l_azk041,l_azk041,l_azk[l_i].azk051,l_azk[l_i].azk052)   
         #CHI-C20056 mark end   -----
      #END IF #CHI-B60062 add #CHI-C20056 mark
      
      IF SQLCA.SQLCODE THEN
         EXIT FOR
      END IF

     #i070_mth()段會用到g_azk.azk01,g_azk.azk02,所以這邊要先將值default進去
      LET g_azk.azk01 =l_azk[l_i].azk01
      LET g_azk.azk02 =l_date

#MOD-B90162 -- begin --
      SELECT COUNT(*) INTO l_cnt FROM azi_file
      WHERE azi01 = l_azk[l_i].azk01 AND aziacti='Y'
      IF l_cnt < 1 THEN
          CONTINUE FOR
      END IF
#MOD-B90162 -- end --
      CALL i070_mth()
   END FOR

   CALL s_showmsg() #CHI-C20056 add

   IF SQLCA.SQLCODE = 0 THEN
      COMMIT WORK
      #CHI-C20056 remove mark start -----
      #MOD-B40107---mark---start---
      IF g_bgjob='N' OR cl_null(g_bgjob) THEN
         LET l_str = cl_getmsg("aoo-302",g_lang)
         CALL cl_msgany(0,0,l_str)
      ELSE
         DISPLAY "Import finished."
      END IF
      #MOD-B40107---mark---end---
      #CHI-C20056 remove mark end   -----
   ELSE
      #ROLLBACK WORK   #FUN-B80035  MARK
      IF g_bgjob='N' OR cl_null(g_bgjob) THEN
         LET g_msg = l_azk[l_i].azk01 CLIPPED,"+",l_date
         CALL cl_err3("ins","azk_file",g_msg,"",SQLCA.sqlcode,"","",1)
      ELSE
         DISPLAY "Import failed."
      END IF
      ROLLBACK WORK    #FUN-B80035  ADD
   END IF
END FUNCTION
#No.FUN-B10021 --end--

#CHI-C20056 add start -----
FUNCTION i070_date_set(p_azk01,p_date_s,p_date_e)
   DEFINE p_azk01      LIKE azk_file.azk01
   DEFINE p_date_s     LIKE type_file.dat
   DEFINE p_date_e     LIKE type_file.dat
   DEFINE l_azk051     LIKE azk_file.azk051
   DEFINE l_azk052     LIKE azk_file.azk052
   DEFINE l_cn         LIKE type_file.num10

   SELECT COUNT(*) INTO l_cn FROM azk_file
    WHERE azk01 = p_azk01
      AND azk02 BETWEEN p_date_s AND p_date_e

   IF l_cn > 0 THEN
      SELECT azk051,azk052 INTO l_azk051,l_azk052 FROM azk_file
       WHERE azk01 = p_azk01
         AND azk02 BETWEEN p_date_s AND p_date_e
       ORDER BY azk02                                 #CHI-D20022
       #ORDER BY azk02 DESC                           #CHI-D20022  
   ELSE
      CALL s_errmsg('',p_azk01,'','aoo1006',1)
   END IF
   RETURN l_azk051,l_azk052

END FUNCTION
#CHI-C20056 add end   -----
