package milang.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlinx.coroutines.launch
import milang.model.RunResult
import milang.service.LangService
import java.io.File
import javax.swing.JFileChooser
import javax.swing.filechooser.FileNameExtensionFilter

@Composable
fun MainWindow() {
    val service = remember { LangService() }
    val scope = rememberCoroutineScope()

    var filePath by remember { mutableStateOf("") }
    var result by remember { mutableStateOf<RunResult?>(null) }
    var running by remember { mutableStateOf(false) }

    val bg = Color(0xFF1E1E1E)
    val surface = Color(0xFF2D2D2D)
    val surfaceLight = Color(0xFF363C42)
    val text = Color(0xFFEEEEEE)
    val muted = Color(0xFFAAAAAA)

    val green = Color(0xFF2E7D32)
    val red = Color(0xFFC62828)
    val yellow = Color(0xFFF57F17)
    val blue = Color(0xFF90CAF9)

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(bg)
            .padding(24.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
            Text(
                text = "VeriLang — Runner",
                color = text,
                fontSize = 28.sp
            )

            Text(
                text = "Analizador de archivos .veri usando Rascal y Kotlin",
                color = muted,
                fontSize = 14.sp
            )
        }

        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            OutlinedTextField(
                value = filePath,
                onValueChange = { filePath = it },
                label = { Text("Ruta del archivo fuente") },
                modifier = Modifier.weight(1f),
                singleLine = true,
                colors = OutlinedTextFieldDefaults.colors(
                    focusedTextColor = text,
                    unfocusedTextColor = text,
                    focusedBorderColor = blue,
                    unfocusedBorderColor = Color.Gray,
                    focusedLabelColor = blue,
                    unfocusedLabelColor = Color.Gray
                ),
                textStyle = LocalTextStyle.current.copy(
                    fontFamily = FontFamily.Monospace,
                    fontSize = 14.sp
                )
            )

            Button(
                onClick = {
                    val chooser = JFileChooser().apply {
                        fileFilter = FileNameExtensionFilter(
                            "Archivos VeriLang (*.veri, *.vl)",
                            "veri",
                            "vl"
                        )
                        currentDirectory = File(System.getProperty("user.dir"))
                    }

                    if (chooser.showOpenDialog(null) == JFileChooser.APPROVE_OPTION) {
                        filePath = chooser.selectedFile.absolutePath
                    }
                },
                colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF455A64))
            ) {
                Text("Buscar")
            }

            Button(
                onClick = {
                    scope.launch {
                        running = true
                        result = service.run(filePath.trim())
                        running = false
                    }
                },
                enabled = filePath.isNotBlank() && !running,
                colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF1565C0))
            ) {
                if (running) {
                    CircularProgressIndicator(
                        modifier = Modifier.size(18.dp),
                        color = text,
                        strokeWidth = 2.dp
                    )
                } else {
                    Text("Correr")
                }
            }
        }

        result?.let { r ->
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .weight(1f)
                    .background(surface, RoundedCornerShape(12.dp))
                    .padding(16.dp)
                    .verticalScroll(rememberScrollState()),
                verticalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                Text(
                    text = "Resultado del análisis",
                    color = text,
                    fontSize = 18.sp
                )

                Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                    StatusChip("Parser", r.parseOk, green, red)
                    StatusChip("Tipos", r.typeCheckOk, green, yellow)
                    StatusChip("Semántica", r.semanticOk, green, yellow)
                }

                val modulesToShow =
                    if (r.modules.isNotEmpty()) r.modules
                    else if (r.module.isNotBlank()) listOf(r.module)
                    else emptyList()

                if (modulesToShow.isNotEmpty()) {
                    SectionBox(
                        title = "Módulos encontrados",
                        content = modulesToShow.joinToString("\n") { "• $it" },
                        color = blue,
                        background = surfaceLight
                    )
                }

                if (r.resumen.isNotBlank()) {
                    SectionBox(
                        title = "Resumen",
                        content = r.resumen,
                        color = muted,
                        background = surfaceLight
                    )
                }

                if (r.error.isNotBlank()) {
                    SectionBox(
                        title = "Error",
                        content = r.error,
                        color = red,
                        background = Color(0xFF3A2B2B)
                    )
                }

                if (r.typeErrors.isNotEmpty()) {
                    SectionBox(
                        title = "Errores de tipos",
                        content = r.typeErrors.joinToString("\n"),
                        color = yellow,
                        background = Color(0xFF3A3324)
                    )
                }

                if (r.semanticErrors.isNotEmpty()) {
                    SectionBox(
                        title = "Errores semánticos",
                        content = r.semanticErrors.joinToString("\n"),
                        color = yellow,
                        background = Color(0xFF3A3324)
                    )
                }

                if (r.codigoFormateado.isNotBlank()) {
                    SectionBox(
                        title = "Resultado generado desde el AST",
                        content = r.codigoFormateado,
                        color = blue,
                        background = surfaceLight
                    )
                }

                if (r.output.isNotEmpty()) {
                    SectionBox(
                        title = "Salida",
                        content = r.output.joinToString("\n"),
                        color = green,
                        background = Color(0xFF26352A)
                    )
                }
            }
        }
    }
}

@Composable
private fun StatusChip(
    label: String,
    ok: Boolean,
    okColor: Color,
    failColor: Color
) {
    val color = if (ok) okColor else failColor
    val status = if (ok) "OK" else "FAIL"

    Box(
        modifier = Modifier
            .background(color.copy(alpha = 0.22f), RoundedCornerShape(6.dp))
            .padding(horizontal = 14.dp, vertical = 7.dp)
    ) {
        Text(
            text = "$label: $status",
            color = color,
            fontSize = 13.sp
        )
    }
}

@Composable
private fun SectionBox(
    title: String,
    content: String,
    color: Color,
    background: Color
) {
    Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
        Text(
            text = title,
            color = color,
            fontSize = 14.sp
        )

        Box(
            modifier = Modifier
                .fillMaxWidth()
                .background(background, RoundedCornerShape(8.dp))
                .padding(12.dp)
        ) {
            Text(
                text = content,
                color = Color(0xFFEEEEEE),
                fontFamily = FontFamily.Monospace,
                fontSize = 13.sp
            )
        }
    }
}