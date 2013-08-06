function write_with_headers(X, file, header_row, header_col, header_col_title)

        % This function will write data to a file given an array of 
        % data, X, an array of row headers, and an array of column headers.
        % The first entry of the row headers should either include the 
        % label for the column headers (i.e., 'subjectID') or an empty
        % string. This assumes that the header column is a cell array
        % and 
        
        % Write the header column first
        nRows = size(X,1);
        nCols = size(X,2);
        
        % Make sure things are the right size
        if length(header_row) ~= nCols
            disp('Invalid length of header row');
        elseif length(header_col) ~= nRows
            disp('Invalid length of header column');
        end
        
        % Determine we're looking at a cell array or an array of numbers
        % for both headers. 
        
        % WRITE HEADER ROW
        
        fprintf(file, '%s,', header_col_title);
        if iscell(header_row)
            for i = 1:nCols
                fprintf(file, '%s', num2str(header_row{i}));
                if i < nCols
                    fprintf(file, ',');
                end
            end
            fprintf(file, '\n');         
        elseif isnumeric(header_row)
            for i = 1:nCols
                fprintf(file, '%f', header_row(i));
                if i < nCols
                    fprintf(file, ',');
                end
            end
            fprintf(file, '\n');  
        end

        for row = 1:nRows
            % Write the header column
            fprintf(file, '%s,', num2str(header_col{row}));
            % write the rest of the column
            for col = 1:nCols
                fprintf(file, '%f', X(row,col));
                if col < nCols
                    fprintf(file,',');
                end
            end
            fprintf(file, '\n');
        end
        
        
        
        
                
                