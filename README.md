# OBS Shaders
These are some shaders I've made for OBS using the [obs-shaderfilter](https://github.com/exeldro/obs-shaderfilter/) plugin.

### Superellipse
`superellipse.shader`

The superellipse shader is similar to the built-in rounded_rect shader in that it visually appears to round the corners of a source (when exponent is set to around 4+).

![obs_roundrect_vs_superellipse](https://github.com/user-attachments/assets/b2f79a46-f025-4f9d-9d3b-49edf963b390)

I vastly prefer the more natural roundness you get from using superellipse as opposed to a standard flat rounded rectangle. It is more computationally expensive, however.

### Edge Fade
`edge_fade.shader`

The edge fade shader is very simple; it fades the alpha in from the edges of your choosing with the strength of your choosing.

![obs_edgefade](https://github.com/user-attachments/assets/467e475d-e825-4d21-bea9-34dc4e237b65)

## Usage Guide
There are two methods to using these shaders in OBS, both will require you to install the aforementioned [obs-shaderfilter](https://github.com/exeldro/obs-shaderfilter/) plugin, first.

After you have the obs-shaderfilter plugin and can verify it appears on a video source's filters -> effects menu, you can now use my filters (as well as many others provided by exeldro).

#### Method #1: Load From Text
- Open the `.shader` file in a text editor (or view raw on the website), select all the text, and copy to clipboard.
- Select the source you want the shader on in OBS and open up Filters.
- Under Effect Filters, click + and add the `User-defined shader` filter.
- In the `Shader text` field, paste the full shader text.
- Click the `Reload effect` button and options will appear to adjust the shader to your liking.

#### Method #2: Load From File
- Save the `.shader` file(s) to a folder on your computer (like the default examples folder in `<obs-install-dir>/data/obs-plugins/obs-shaderfilter/examples`).
- Select the source you want the shader on in OBS and open up Filters.
- Under Effect Filters, click + and add the `User-defined shader` filter.
- Check the `Load shader text from file` box, and open the dialog to select the shader file you want to use.
- If options don't automatically appear, click the `Reload effect` button and adjust the shader to your liking
