function createParSetWd(parent, type, y_pos, text_label, wd_string, wd_value, wd_callback, tag)
    global VSAS_main
    position_text = [12, y_pos, 200, 20];
    position_edit = [220, y_pos, 50, 20];
    position_pop  = [220, y_pos, 160, 20];
    uicontrol(parent, ...
              'Style', 'text', ...
              'Position', position_text, ...
              'HorizontalAlignment', 'left', ...
              'String', text_label, ...
              'Fontname', VSAS_main.FONT_NAME, ...
              'FontSize', VSAS_main.LABEL_FONT_SIZE, ...
              'Tag', [tag,'_text'], ...
              'Visible', 'on');
    
    if strcmp(type, 'edit') == 1
        uicontrol(parent, ...
                  'Style', 'edit', ...
                  'Position', position_edit,...
                  'String', wd_string, ...
                  'Callback', wd_callback, ...
                  'Tag', [tag, '_edit'], ...
                  'Visible', 'on');
    else
        uicontrol(parent, ...
                  'Style', 'popupmenu', ...
                  'Handlevisibility', 'On', ...
                  'Position', position_pop, ...
                  'String', wd_string, ...
                  'Value', wd_value, ...
                  'Fontname', VSAS_main.FONT_NAME, ...
                  'FontSize', VSAS_main.MENU_FONT_SIZE, ...
                  'Callback', wd_callback, ...
                  'Tag', [tag, '_pop'], ...
                  'Visible', 'on');
    end
    
end