"""Interfaz Streamlit para la gestión de expediciones científicas antárticas."""
import pandas as pd
import streamlit as st
from db.dao import query
from services.expeditions import (
    summary, bases, create_expedition, countries, list_bases, create_base,
    update_base, deactivate_base, list_samples, create_sample, update_sample,
    deactivate_sample,
)

st.set_page_config(page_title="Expediciones Científicas Antárticas", page_icon="❄️", layout="wide")
st.title("❄️ Sistema Integral de Gestión de Expediciones Científicas en la Antártida")
st.caption("Registro y administración de expediciones, bases científicas y muestras.")

# Pantalla inicial: resumen breve, sin dashboard ni gráficos.
counts = summary()
c1, c2 = st.columns(2)
c1.metric("Expediciones registradas", counts["expeditions"])
c2.metric("Muestras activas", counts["samples"])

page = st.sidebar.radio("Secciones", ["Inicio", "Registrar expedición", "Administrar bases", "Administrar muestras"])

if page == "Inicio":
    st.subheader("Expediciones registradas")
    rows = query(
        "SELECT e.cod_expedicion,bc.nombre AS base_cientifica,e.fecha_inicio,e.duracion,e.capacidad_maxima "
        "FROM expedicion e JOIN base_cientifica bc ON bc.cod_base=e.cod_base "
        "ORDER BY e.fecha_inicio DESC,e.cod_expedicion DESC"
    )
    st.dataframe(pd.DataFrame(rows), use_container_width=True, hide_index=True)
    st.subheader("Muestras registradas")
    st.dataframe(pd.DataFrame(list_samples()), use_container_width=True, hide_index=True)

elif page == "Registrar expedición":
    st.subheader("Formulario de registro de expediciones")
    available_bases = bases()
    if not available_bases:
        st.warning("No hay bases científicas activas. Registre una base antes de crear una expedición.")
    else:
        with st.form("expedition_form"):
            base = st.selectbox("Base científica", available_bases, format_func=lambda x: x["nombre"])
            start_date = st.date_input("Fecha de inicio")
            duration = st.number_input("Duración (días)", min_value=1, step=1)
            capacity = st.number_input("Capacidad máxima", min_value=1, step=1)
            submitted = st.form_submit_button("Registrar expedición", use_container_width=True)
        if submitted:
            try:
                create_expedition(base["cod_base"], start_date, duration, capacity)
                st.success("Expedición registrada correctamente.")
                st.rerun()
            except Exception as exc:
                st.error(f"No se pudo registrar la expedición: {exc}")

elif page == "Administrar bases":
    st.subheader("Crear base científica")
    country_rows = countries()
    if not country_rows:
        st.warning("Primero debe existir al menos un país en la tabla pais.")
    else:
        with st.form("create_base"):
            country = st.selectbox("País responsable", country_rows, format_func=lambda x: x["nombre_oficial"])
            name = st.text_input("Nombre de la base")
            location = st.text_input("Ubicación")
            capacity = st.number_input("Capacidad máxima", min_value=1, step=1)
            budget = st.number_input("Presupuesto", min_value=0.0, step=1000.0)
            isolation = st.text_input("Nivel de aislamiento")
            submitted = st.form_submit_button("Guardar base")
        if submitted:
            try:
                create_base(name, location, capacity, budget, isolation, country["cod_pais"])
                st.success("Base científica creada correctamente.")
                st.rerun()
            except Exception as exc:
                st.error(f"No se pudo crear la base: {exc}")

    st.divider()
    st.subheader("Consultar y modificar bases científicas")
    base_rows = list_bases()
    st.dataframe(pd.DataFrame(base_rows), use_container_width=True, hide_index=True)
    if base_rows and country_rows:
        selected = st.selectbox("Base científica", base_rows,
                                format_func=lambda x: f'{x["nombre"]} (código {x["cod_base"]})',
                                key="selected_base")
        country_index = next((i for i, c in enumerate(country_rows) if c["cod_pais"] == selected["cod_pais"]), 0)
        with st.form("update_base"):
            edit_country = st.selectbox("País responsable", country_rows, index=country_index,
                                        format_func=lambda x: x["nombre_oficial"])
            edit_name = st.text_input("Nombre", value=selected["nombre"])
            edit_location = st.text_input("Ubicación", value=selected["ubicacion"])
            edit_capacity = st.number_input("Capacidad máxima", min_value=1,
                                             value=int(selected["capacidad_maxima"]))
            edit_budget = st.number_input("Presupuesto", min_value=0.0,
                                          value=float(selected["presupuesto"] or 0))
            edit_isolation = st.text_input("Nivel de aislamiento", value=selected["nivel_aislamiento"] or "")
            update = st.form_submit_button("Guardar cambios")
        if update:
            try:
                update_base(selected["cod_base"], edit_name, edit_location, edit_capacity,
                            edit_budget, edit_isolation, edit_country["cod_pais"])
                st.success("Base modificada correctamente.")
                st.rerun()
            except Exception as exc:
                st.error(f"No se pudo modificar la base: {exc}")
        if st.button("Desactivar base seleccionada", type="secondary"):
            try:
                deactivate_base(selected["cod_base"])
                st.success("Base desactivada. Se conserva su historial y sus relaciones.")
                st.rerun()
            except Exception as exc:
                st.error(f"No se pudo desactivar la base: {exc}")

elif page == "Administrar muestras":
    st.subheader("Crear muestra científica")
    with st.form("create_sample"):
        name = st.text_input("Nombre de la muestra")
        description = st.text_area("Descripción")
        found_date = st.date_input("Fecha de hallazgo")
        conservation = st.text_input("Estado de conservación")
        sample_type = st.selectbox("Clasificación", ["Biológica", "Geológica", "Climática"])
        detail_label = {"Biológica": "Atributo específico", "Geológica": "Composición", "Climática": "Variable medida"}[sample_type]
        detail = st.text_input(detail_label)
        submitted = st.form_submit_button("Guardar muestra")
    if submitted:
        try:
            create_sample(name, description, found_date, conservation, sample_type, detail)
            st.success("Muestra científica creada correctamente.")
            st.rerun()
        except Exception as exc:
            st.error(f"No se pudo crear la muestra: {exc}")

    st.divider()
    st.subheader("Consultar y modificar muestras")
    sample_rows = list_samples()
    st.dataframe(pd.DataFrame(sample_rows), use_container_width=True, hide_index=True)
    if sample_rows:
        selected = st.selectbox("Muestra científica", sample_rows,
                                format_func=lambda x: f'{x["nombre"]} (código {x["cod_muestra"]})',
                                key="selected_sample")
        current_type = selected["tipo"] if selected["tipo"] in ["Biológica", "Geológica", "Climática"] else "Biológica"
        with st.form("update_sample"):
            edit_name = st.text_input("Nombre", value=selected["nombre"])
            edit_description = st.text_area("Descripción", value=selected["descripcion"] or "")
            edit_date = st.date_input("Fecha de hallazgo", value=selected["fecha_hallazgo"])
            edit_conservation = st.text_input("Estado de conservación", value=selected["estado_conservacion"] or "")
            edit_type = st.selectbox("Clasificación", ["Biológica", "Geológica", "Climática"],
                                     index=["Biológica", "Geológica", "Climática"].index(current_type))
            edit_detail_label = {"Biológica": "Atributo específico", "Geológica": "Composición", "Climática": "Variable medida"}[edit_type]
            edit_detail = st.text_input(edit_detail_label, value=selected["detalle"] or "")
            update = st.form_submit_button("Guardar cambios")
        if update:
            try:
                update_sample(selected["cod_muestra"], edit_name, edit_description, edit_date,
                              edit_conservation, edit_type, edit_detail)
                st.success("Muestra modificada correctamente.")
                st.rerun()
            except Exception as exc:
                st.error(f"No se pudo modificar la muestra: {exc}")
        if st.button("Desactivar muestra seleccionada", type="secondary"):
            try:
                deactivate_sample(selected["cod_muestra"])
                st.success("Muestra desactivada. Se conserva su historial de recolección.")
                st.rerun()
            except Exception as exc:
                st.error(f"No se pudo desactivar la muestra: {exc}")