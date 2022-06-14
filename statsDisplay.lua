function onload()
    for i=1, 3 do
         self.createButton({
              click_function = "none",
              function_owner = self,
              label = "0",
              width = 0,
              height = 0,
              font_size = 150,
              font_color = "White",
              position = {.3, 0.1, -0.6 + (i-1) * 0.58}
         })
    end
end

function updateLabels(param)
    for i=0, 2 do
         self.editButton({
              index = i,
              label = param[i + 1]
         })
    end
end