function print_svg(filename)
% Saves the current figure as an SVG in the figure_panels folder, then
% closes it
panel_path = fullfile(files_path, 'figure_panels', filename);
set(gca,'FontName','Calibri');
print(panel_path, '-dsvg')
close(gcf)

end