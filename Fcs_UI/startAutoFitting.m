function startAutoFitting()

% ����µ�ʵ�����ݣ�������Ҫȷ�����㣺
% 1. delta rho Ҳ����С��ɢ���е�ɢ�䳤���ܶȵ�ȡֵ
% 2. Unit of q: nm-1 ���������� [1e-3, 10] ֮��
% 4. I(q)��Ҫȡ����

%% INITIALIZATION OF GLOBAL VARIABLES ����ȫ�ֱ���
    global VSAS_main
    global Material;
    INFO = VSAS_main.FIT_INFO.INFO;

% LOAD SERIE OF EXPERIMENTAL DATA ����ʵ������
    FileName  = VSAS_main.file_name;
    PathName  = VSAS_main.file_path;   % �������ݴ�ŵ��ļ���·��
    
% RECORD TIME ��¼��ǰʱ��
    time_text = datestr(now,30);                          % ��¼��ǰʱ��
    
% INITIALIZATION OF FINAL REPORT ��ʼ���ܱ���
    Final_report = table();
    result_table = table();

% START PROGRAMME ��ʼ���� 

    SampleName = FileName;

% PRETREATMENT OF EXPERIMENTAL  DATA ʵ������Ԥ����
    data = VSAS_main.dt_E_data;
    
    % ��λ����
    % data(:,1) = data(:,1).*10;                          % ��q���е�λ����
    % data(:,2) = data(:,2)./96*10000;                    % ��I(q)���е�λ����
    
    % INFO.E should always be Log result
    INFO.I_exp = INFO.E;
    INFO.I_exp_log = INFO.E;
    INFO.dI_exp_log = INFO.dE;
    
    % ���ݹ�ģѹ��
    % data = REDUCE_DATA(data, 2);

%% SET OPIMIZATION OPTIONS Ԥ���Ż����򳬲���
    program_par_table = VSAS_main.FIT_INFO.program_par_table;
    fit_times   = program_par_table.fit_times;                                                       % ����ϴ���
    % stop_loss   = program_par_table.stop_loss;                                                     % ֹͣ�������ʧ������CorMap������ 10 �ȽϺ���
    check_limit = program_par_table.check_limit;                                                     % GridSearch ѭ����������
    plot_num    = program_par_table.plot_num;
        
%% SET LOSS FUNCTIONS ������ʧ����
    if (strcmp(program_par_table.loss_type, 'Chi2'))
        Loss_fun_base = @LOSS_Chi2;
    elseif (strcmp(program_par_table.loss_type, 'MSE'))
        Loss_fun_base = @LOSS_MSE;
    end
    
    Loss_fun_CorMap = @LOSS_CorMap;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% START TIMING
    t = tic();

%% BUIDING INFO
    Mat = load(VSAS_main.FIT_INFO.model_table.material_type);
    Material = getfield(Mat,VSAS_main.FIT_INFO.model_table.material_type);
    P_Value_Table = load('P_Value_Table');
    P_Value_Table = getfield(P_Value_Table,'P_Value_Table');
    
%% INITIALIZATION OF THE ALGORITHM �Ż������ʼ��
    X0      = array2table(zeros(fit_times,INFO.ParNum), ...
                          'VariableNames', INFO.VarNames);
    XF      = array2table(zeros(fit_times,INFO.ParNum), ...
                          'VariableNames', INFO.VarNames);
    XB      = array2table(zeros(fit_times,INFO.ParNum), ...
                          'VariableNames', INFO.VarNames);
    CorM_X0      = zeros(1,fit_times);
    Chi2_X0      = zeros(1,fit_times);
    CorM_XF      = zeros(1,fit_times);
    Chi2_XF      = zeros(1,fit_times);
    CorM_XB      = zeros(1,fit_times);
    Chi2_XB      = zeros(1,fit_times);
    Max_Patch_XB = zeros(1,fit_times);
    P_Value_XB   = zeros(1,fit_times);
    Result       = zeros(fit_times, INFO.ParNum + 1);
    print_color        = [1, 0.5, 0];

%% START OPTIMIZATION ��ʼ�Ż�
    for i = 1:fit_times
        check_times = 1;
        tim_total   = Cal_process_start('Current cycle is:', i, fit_times);

        %% Baysian Optimization
        BO_result    = BAYSIAN_OPTIMIZATION(INFO, Loss_fun_base);
        x0           = BO_result.XAtMinObjective;                       % The parameters at min point
        X0(i,:)      = x0;
        CorM_X0(1,i) = LOSS_VALUE(x0, INFO, Loss_fun_CorMap); 
        Chi2_X0(1,i) = LOSS_VALUE(x0, INFO, Loss_fun_base);

        drawnow();

         if (VSAS_main.flag_fit == 1) && (ishandle(VSAS_main.wd_waitbar))
             VSAS_main = VSAS_main.fitProceed();
         else
             VSAS_main = VSAS_main.stopFittingProgram();
             return
         end
            

        %% Gradient Descent
        tim_f        = Cal_process_start('Gradient Descent:', i, fit_times);
        x_fmincon    = FMINCON(x0, INFO, Loss_fun_base);
        XF(i,:)      = x_fmincon;
        CorM_XF(1,i) = LOSS_VALUE(x_fmincon, INFO, Loss_fun_CorMap);
        Chi2_XF(1,i) = LOSS_VALUE(x_fmincon, INFO, Loss_fun_base); 
        Cal_process_end(tim_f);

        drawnow();
        if (VSAS_main.flag_fit == 1) && (ishandle(VSAS_main.wd_waitbar))
            VSAS_main = VSAS_main.fitProceed();
        else
            VSAS_main = VSAS_main.stopFittingProgram();
            return
        end
        cprintf(print_color, strcat('\t', 'Best result:', 32, num2str(Chi2_XF(1,i)), '\n'));

        %% Grid Search
        tim_b    = Cal_process_start('Grid Search:', i, fit_times);
        x_better = GRID_SEARCH(x_fmincon, INFO, Loss_fun_CorMap);
        while(~isequal(table2array(x_fmincon), table2array(x_better)) && check_times < check_limit)
            x_fmincon   = FMINCON(x_better, INFO, Loss_fun_base);
            x_better    = GRID_SEARCH(x_fmincon, INFO, Loss_fun_CorMap);
            check_times = check_times + 1;
        end

        drawnow();
        if (VSAS_main.flag_fit == 1) && (ishandle(VSAS_main.wd_waitbar))
            VSAS_main = VSAS_main.fitProceed();
        else
            VSAS_main = VSAS_main.stopFittingProgram();
            return
        end

        
        XB(i,:)           = x_better;
        VB_temp           = FIT_VALUE(x_better, INFO);
        Max_Patch         = GET_MAX_PATCH(VB_temp, INFO);
        Max_Patch_XB(1,i) = Max_Patch;
        try
            P_Value_XB(1,i)   = P_Value_Table(INFO.Data_size+1 ,Max_Patch);
        catch
            P_Value_XB(1,i)   = 0;
        end
        CorM_XB(1,i)      = LOSS_VALUE(x_better, INFO, Loss_fun_CorMap);
        Chi2_XB(1,i)      = LOSS_VALUE(x_better, INFO, Loss_fun_base);
        Loss              = LOSS_VALUE(x_better, INFO, Loss_fun_base);
        Result(i,:)       = [table2array(x_better) Loss];
        Cal_process_end(tim_b);
        Cal_process_end(tim_total);

    end 
    CorM_history       = [CorM_X0; CorM_XF; CorM_XB];
    Chi2_history       = [Chi2_X0; Chi2_XF; Chi2_XB];
    [Best_num, Output] = DATASET2OUTPUT(Result, INFO);
    var_value = VAR_INVERSE_NORMALIZATION(XB(Best_num,:), INFO);
    VSAS_main = VSAS_main.setVarValue(table2array(var_value));

%% TOTAL TIME COST
    Total_time = round(toc(t),2);
    Mean_time  = round(Total_time / fit_times, 2);
    cprintf(print_color, strcat('Total time used:', 32, num2str(Total_time), 's\n'));
                      
%% OUTPUT TO USER
    Save_Path                 = [PathName, time_text, '\']; 
    Save_Name                 = [SampleName(1:end - 4), '-', time_text];
    report                    = OUTPUT_REPORT(Best_num, XB, Chi2_history, CorM_history, Max_Patch_XB, P_Value_XB, INFO);
    X_Best                    = report(Best_num,:);
    final_result              = OUTPUT_FINALREPORT(X_Best, SampleName, Total_time, Mean_time, fit_times, INFO);
    Final_report(1, :)        = final_result;
    
    result_table.X0           = {X0};
    result_table.XF           = {XF};
    result_table.XB           = {XB};
    result_table.FIT_INFO     = {VSAS_main.FIT_INFO};
    result_table.Best_num     = Best_num;
    result_table.total_time   = Total_time;
    result_table.time_text    = {time_text};
    result_table.SampleName   = {SampleName};
    result_table.PathName     = {PathName};
    result_table.report       = {report};
    result_table.X_Best       = X_Best;
    result_table.final_result = final_result;
    result_table.Final_report = Final_report;
    result_table.Save_Name    = {Save_Name};
    result_table.Save_Path    = {Save_Path};
    result_table.data = {data};
    
    VSAS_main.result_table    = result_table;
    VSAS_main = VSAS_main.fitFinish();
    
    if exist(Save_Path, 'dir') == 0                                         % �����ļ��в����ڣ���ֱ�Ӵ���
        mkdir(Save_Path);
    end
    
    save([Save_Path,'result_table.mat'], 'result_table');
    
end
