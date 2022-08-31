function settingsButtonCallback(~, ~)
    global VSAS_main
    settings_figure = figure('menubar', 'none');
    width = 1000;
    height = 740;
    VSAS_main.wd_set_figure = settings_figure;
    
    set(settings_figure, ... 
        'position', [(VSAS_main.screen_size(3) - width)/2 ...
                     (VSAS_main.screen_size(4) - height)/2 ... 
                     width ... 
                     height], ... 
        'NumberTitle', 'off', ... 
        'Name', 'Hyperparameters Setting');
    
    setting_panels_title     = {'Variable Ranges', 'Model Settings', 'Bayesian Optimization', 'Gradient Descend', 'Grid Search', 'Program Parameters'};
    setting_panels_title_tag = {'set_vr','set_model', 'set_bo', 'set_gd', 'set_gs', 'set_par'};
    
    panel_distance_y = 20;
    
%% 'Variable Ranges' penel labels
    var_names   = VSAS_main.FIT_INFO.var_names_cell;
    var_symbols = table2cell(VSAS_main.FIT_INFO.var_symbol_table);
    var_ranges  = table2cell(VSAS_main.FIT_INFO.var_range_table);
    panel_height = (size(var_names, 2) - 1)*25 + 50 + 10;
    panel_pos_left = height - panel_height - 10;
    y_pos = panel_height - 50;
    panel_vr = uipanel(settings_figure, ...
                       'Units', 'pixel', ...
                       'Position', [50 panel_pos_left 400 panel_height], ...
                       'Title', setting_panels_title{1}, ...
                       'Fontname', VSAS_main.FONT_NAME, ...
                       'FontSize', VSAS_main.PANEL_FONT_SIZE, ...
                       'Tag', setting_panels_title_tag{1}, ...
                       'Visible', 'on');
    
    for i = 1:size(var_names, 2)
        position_annotation = [10 y_pos+5, 50, 20];
        position_connect    = [180 y_pos+5, 50, 20];
        position_text_min   = [125, y_pos, 50, 20];
        position_text_max   = [215, y_pos, 50, 20];
        annotation(panel_vr, 'textbox', ...
                   'Units', 'pixel', ...
                   'Position', position_annotation, ...
                   'String', var_symbols{i}, ...
                   'interpreter', 'latex', ...
                   'EdgeColor', [0.941, 0.941, 0.941], ...
                   'FontSize', VSAS_main.ANNOTATION_FONT_SIZE, ...
                   'Tag', ['set_vr_',var_names{i}], ...
                   'FitBoxToText', 'on', ...
                   'Visible', 'on');
        annotation(panel_vr, 'textbox', ...
                   'Units', 'pixel', ...
                   'Position', position_connect, ...
                   'String', '$\sim$', ...
                   'interpreter', 'latex', ...
                   'EdgeColor', [0.941, 0.941, 0.941], ...
                   'FontSize', VSAS_main.ANNOTATION_FONT_SIZE, ...
                   'Tag', ['set_vr_c_',var_names{i}], ...
                   'FitBoxToText', 'on', ...
                   'Visible', 'on');
        edit_min = uicontrol(panel_vr, ...
                             'Style', 'edit', ...
                             'String', num2str(var_ranges{i}(1)), ...
                             'Position', position_text_min,...
                             'Tag', ['set_vr_',var_names{i}, '_min'], ...
                             'Visible', 'on');
        edit_max = uicontrol(panel_vr, ...
                             'Style', 'edit', ...
                             'String', num2str(var_ranges{i}(2)), ...
                             'Position', position_text_max,...
                             'Tag', ['set_vr_',var_names{i}, '_max'], ...
                             'Visible', 'on');
        BindSetVarRangeEdit(edit_min, edit_max, var_names{i});
        y_pos = y_pos - 25;
        
    end
    
%% 'Model Settings' penel labels
    model_settings_label    = {'Material type','$\Delta\rho$','$\alpha$'};
    model_settings_tag      = {'set_ms_mt','rho','alpha'};
    model_settings_callback = {@SetMatTypeCallback, ...
                               @SetRhoUnitCallback, ...
                               @SetAlphaCallback};
    panel_height = (size(model_settings_label, 2) - 1)*25 + 50 + 10;
    panel_pos_left = panel_pos_left - panel_height - panel_distance_y;
    y_pos = panel_height - 50;
    panel_ms = uipanel(settings_figure, ...
                       'Units', 'pixel', ...
                       'Position', [50 panel_pos_left 400 panel_height], ...
                       'Title', setting_panels_title{2}, ...
                       'Fontname', VSAS_main.FONT_NAME, ...
                       'FontSize', VSAS_main.PANEL_FONT_SIZE, ...
                       'Tag', setting_panels_title_tag{2}, ...
                       'Visible', 'on');
    material_type = matType2num(VSAS_main.FIT_INFO.model_table.material_type);
    createParSetWd(panel_ms, ...
                   'popmenu', ...
                   y_pos, ...
                   model_settings_label{1}, ...
                   ['ASZ|' ...
                    'AlScZr_SANS_Linear|' ...
                    'AlScZr_SAXS_Linear'], ...
                    material_type, ...
                    model_settings_callback{1}, ...
                    model_settings_tag{1})  
    rho_unit  = VSAS_main.FIT_INFO.model_table.rho_unit;
    rho_order = VSAS_main.FIT_INFO.model_table.rho_order;
    alpha                 = num2str(VSAS_main.FIT_INFO.model_table.alpha);
    model_settings_value  = {rho_unit, alpha};
    y_pos = y_pos - 25;      
    for i=1:2
        position_annotation = [10 y_pos+2, 50, 20];
        position_equal      = [45 y_pos+2, 50, 20];
        position_text       = [75, y_pos-2, 50, 20];
        annotation(panel_ms, 'textbox', ...
                   'Units', 'pixel', ...
                   'Position', position_annotation, ...
                   'String', model_settings_label{i+1}, ...
                   'interpreter', 'latex', ...
                   'EdgeColor', [0.941, 0.941, 0.941], ...
                   'FontSize', VSAS_main.ANNOTATION_FONT_SIZE, ...
                   'Tag', ['set_ms_',model_settings_tag{i+1}], ...
                   'FitBoxToText', 'on', ...
                   'Visible', 'on');
        annotation(panel_ms, 'textbox', ...
                   'Units', 'pixel', ...
                   'Position', position_equal, ...
                   'String', '$=$', ...
                   'interpreter', 'latex', ...
                   'EdgeColor', [0.941, 0.941, 0.941], ...
                   'FontSize', VSAS_main.ANNOTATION_FONT_SIZE, ...
                   'Tag', ['set_ms_e_',model_settings_tag{i+1}], ...
                   'FitBoxToText', 'on', ...
                   'Visible', 'on');
        uicontrol(panel_ms, ...
                  'Style', 'edit', ...
                  'String', model_settings_value{i}, ...
                  'Position', position_text,...
                  'Callback', model_settings_callback{i+1}, ...
                  'Tag', ['set_ms_text_',model_settings_tag{i+1}], ...
                  'Visible', 'on');             
        if i==1
            position_dot   = [125, y_pos+2, 50, 20];
            position_order  = [160, y_pos-2, 50, 20];
            annotation(panel_ms, 'textbox', ...
                       'Units', 'pixel', ...
                       'Position', position_dot, ...
                       'String', '$.E$', ...
                       'interpreter', 'latex', ...
                       'EdgeColor', [0.941, 0.941, 0.941], ...
                       'FontSize', VSAS_main.ANNOTATION_FONT_SIZE, ...
                       'Tag', ['set_ms_dot_',model_settings_tag{i+1}], ...
                       'FitBoxToText', 'on', ...
                       'Visible', 'on');
            uicontrol(panel_ms, ...
                      'Style', 'edit', ...
                      'String', rho_order, ...
                      'Position', position_order,...
                      'Callback', @SetRhoOrderCallback, ...
                      'Tag', ['set_ms_order_',model_settings_tag{i+1}], ...
                      'Visible', 'on');
        end
        y_pos = y_pos - 25;
    end
    
%% Bayesian Optimization', 'Grid Search' and 'Program Parameters'
    setting_wd_title = {{'Number of objective evaluations',...
                         'Number of seed points'}, ...
                        {}, ...
                        {'Range of grids', ...
                         'Number of points', ...
                         'Search mode'}, ...
                        {'Number of fitting', ...
                         'Threshold of valid loss', ...
                         'Max limit of check times', ...
                         'Loss function'}};
    setting_wd_type = {{'edit',...
                        'edit'}, ...
                       {}, ...
                       {'edit', ...
                        'edit', ...
                        'popmenu'}, ...
                       {'edit', ...
                        'edit', ...
                        'edit', ...
                        'popmenu'}};
    BO_opt_table = VSAS_main.FIT_INFO.BO_opt_table;
    GD_opt_table = VSAS_main.FIT_INFO.GD_opt_table;
    GS_opt_table = VSAS_main.FIT_INFO.GS_opt_table;
    program_par_table = VSAS_main.FIT_INFO.program_par_table;
    setting_wd_string = {{num2str(BO_opt_table.MaxObjectiveEvaluations),...
                          num2str(BO_opt_table.NumSeedPoints)}, ...
                         {}, ...
                         {num2str(GS_opt_table.point_range), ...
                          num2str(GS_opt_table.point_number), ...
                          'Random|No Random'}, ...
                         {num2str(program_par_table.fit_times), ...
                          num2str(program_par_table.stop_loss), ...
                          num2str(program_par_table.check_limit), ...
                          'Chi2|MSE'}};
    setting_wd_value = {{'',...
                         ''}, ...
                        {}, ...
                        {'', ...
                         '', ...
                         GSmode2num(GS_opt_table.search_mode)}, ...
                        {'', ...
                         '', ...
                         '', ...
                         getLossId(program_par_table.loss_type)}};
    setting_callback = {{@SetBONumObjEvaCallback,...
                         @SetBONumSeedCallback}, ...
                        {}, ...
                        {@SetGSRangCallback, ...
                         @SetGSNumPointCallback, ...
                         @SetGSModeCallback}, ...
                        {@SetPPNumFitCallback, ...
                         @SetPPThreLossCallback, ...
                         @SetPPCheckLimCallback, ...
                         @SetPPLossType}};               
    setting_wd_tag = {{'set_bo_moe',...
                       'set_bo_nsp'}, ...
                      {}, ...
                      {'set_gs_pr', ...
                       'set_gs_pn', ...
                       'set_gs_sm'}, ...
                      {'set_pp_edit', ...
                       'set_pp_edit', ...
                       'set_pp_edit', ...
                       'set_pp_loss'}};               
    panel_pos = height - 10;
    for i=1:4
        panel_height = (size(setting_wd_title{i}, 2) - 1)*25 + 50 + 10;
        panel_pos = panel_pos - panel_height;
        panel = uipanel(settings_figure, ...
                        'Units', 'pixel', ...
                        'Position', [550 panel_pos 400 panel_height], ...
                        'Title', setting_panels_title{i+2}, ...
                        'Fontname', VSAS_main.FONT_NAME, ...
                        'FontSize', VSAS_main.PANEL_FONT_SIZE, ...
                        'Tag', setting_panels_title_tag{i+2}, ...
                        'Visible', 'on');
        y_pos = panel_height - 50;
        for j=1:size(setting_wd_type{i}, 2)
            createParSetWd(panel, ...
                           setting_wd_type{i}{j}, ...
                           y_pos, ...
                           setting_wd_title{i}{j}, ...
                           setting_wd_string{i}{j}, ...
                           setting_wd_value{i}{j}, ...
                           setting_callback{i}{j}, ...
                           setting_wd_tag{i}{j})  
            y_pos = y_pos - 25;
        end
        panel_pos = panel_pos - panel_distance_y;
    end
    
    uicontrol(settings_figure, ...
              'style', 'pushbutton', ...
              'String', 'Save', ...
              'Fontname', VSAS_main.FONT_NAME, ...
              'FontSize', VSAS_main.LABEL_FONT_SIZE, ...
              'position', [(width-120)/2 50 120 30], ...
              'Enable', 'on', ...
              'Callback', @SetSaveButtonCallback, ...
              'Tag', 'set_save', ...
              'Visible', 'on');
    
end

function num = matType2num(mat_type)
    num = 1;
    if strcmp(mat_type, 'ASZ') == 1
        num = 1;
    elseif strcmp(mat_type, 'AlScZr_SANS_Linear') == 1
        num = 2;
    elseif strcmp(mat_type, 'AlScZr_SAXS_Linear') == 1
        num = 3;
    end
end

function num = getLossId(loss_type)
    num = 1;
    if strcmp(loss_type, 'Chi2') == 1
        num = 1;
    elseif strcmp(loss_type, 'MSE') == 1
        num = 2;
    end
end

function num = GSmode2num(mat_type)
    num = 1;
    if strcmp(mat_type, 'Random') == 1
        num = 1;
    elseif strcmp(mat_type, 'No Random') == 1
        num = 2;
    end
end

function [rho_unit, order] = rho_raw2str(rho_raw)

    order = floor(log10(rho_raw));
    rho_unit = rho_raw/(10^order);
    order = num2str(order);
    rho_unit = num2str(rho_unit);
    
end