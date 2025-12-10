//
//  ProductoFormViewController.swift
//  planiq
//
//  Created by Asbel on 10/12/25.
//

import UIKit
import PhotosUI

final class ProductoFormViewController: UIViewController {
    
    // MARK: - Properties
    
    private var producto: Producto?
    private let viewModel: ProductosViewModel
    private var selectedImage: Data?
    
    private var categorias: [Categoria] = []
    private var marcas: [Marca] = []
    private var unidades: [Unidad] = []
    
    private var selectedCategoria: Categoria?
    private var selectedMarca: Marca?
    private var selectedUnidad: Unidad?
    
    // MARK: - UI Components
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.showsVerticalScrollIndicator = false
        return sv
    }()
    
    private let contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let imageContainerView: UIView = {
        let v = UIView()
        v.backgroundColor = .systemGray6
        v.layer.cornerRadius = 12
        v.layer.borderWidth = 2
        v.layer.borderColor = UIColor.systemGray4.cgColor
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let productoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 10
        iv.image = UIImage(systemName: "camera.fill")
        iv.tintColor = .systemGray3
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let changePhotoButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Cambiar foto", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let codigoTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Código (auto-generado si vacío)"
        tf.borderStyle = .roundedRect
        tf.font = .monospacedSystemFont(ofSize: 16, weight: .medium)
        tf.autocapitalizationType = .allCharacters
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let descripcionTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Descripción del producto *"
        tf.borderStyle = .roundedRect
        tf.font = .systemFont(ofSize: 16)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let categoriaButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Seleccionar Categoría", for: .normal)
        btn.contentHorizontalAlignment = .left
        btn.titleLabel?.font = .systemFont(ofSize: 16)
        btn.backgroundColor = .systemGray6
        btn.layer.cornerRadius = 8
        btn.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let marcaButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Seleccionar Marca", for: .normal)
        btn.contentHorizontalAlignment = .left
        btn.titleLabel?.font = .systemFont(ofSize: 16)
        btn.backgroundColor = .systemGray6
        btn.layer.cornerRadius = 8
        btn.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let unidadButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Seleccionar Unidad", for: .normal)
        btn.contentHorizontalAlignment = .left
        btn.titleLabel?.font = .systemFont(ofSize: 16)
        btn.backgroundColor = .systemGray6
        btn.layer.cornerRadius = 8
        btn.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let estadoLabel: UILabel = {
        let label = UILabel()
        label.text = "Estado activo"
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let estadoSwitch: UISwitch = {
        let sw = UISwitch()
        sw.isOn = true
        sw.onTintColor = .systemGreen
        sw.translatesAutoresizingMaskIntoConstraints = false
        return sw
    }()
    
    private let saveButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Guardar Producto", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        btn.backgroundColor = .systemGreen
        btn.layer.cornerRadius = 12
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    // MARK: - Init
    
    init(producto: Producto?, viewModel: ProductosViewModel) {
        self.producto = producto
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadPickerData()
        configureForEditing()
        setupActions()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = producto == nil ? "Nuevo Producto" : "Editar Producto"
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(imageContainerView)
        imageContainerView.addSubview(productoImageView)
        contentView.addSubview(changePhotoButton)
        contentView.addSubview(codigoTextField)
        contentView.addSubview(descripcionTextField)
        contentView.addSubview(categoriaButton)
        contentView.addSubview(marcaButton)
        contentView.addSubview(unidadButton)
        contentView.addSubview(estadoLabel)
        contentView.addSubview(estadoSwitch)
        contentView.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            imageContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            imageContainerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageContainerView.widthAnchor.constraint(equalToConstant: 120),
            imageContainerView.heightAnchor.constraint(equalToConstant: 120),
            
            productoImageView.topAnchor.constraint(equalTo: imageContainerView.topAnchor, constant: 4),
            productoImageView.leadingAnchor.constraint(equalTo: imageContainerView.leadingAnchor, constant: 4),
            productoImageView.trailingAnchor.constraint(equalTo: imageContainerView.trailingAnchor, constant: -4),
            productoImageView.bottomAnchor.constraint(equalTo: imageContainerView.bottomAnchor, constant: -4),
            
            changePhotoButton.topAnchor.constraint(equalTo: imageContainerView.bottomAnchor, constant: 8),
            changePhotoButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            codigoTextField.topAnchor.constraint(equalTo: changePhotoButton.bottomAnchor, constant: 24),
            codigoTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            codigoTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            codigoTextField.heightAnchor.constraint(equalToConstant: 50),
            
            descripcionTextField.topAnchor.constraint(equalTo: codigoTextField.bottomAnchor, constant: 16),
            descripcionTextField.leadingAnchor.constraint(equalTo: codigoTextField.leadingAnchor),
            descripcionTextField.trailingAnchor.constraint(equalTo: codigoTextField.trailingAnchor),
            descripcionTextField.heightAnchor.constraint(equalToConstant: 50),
            
            categoriaButton.topAnchor.constraint(equalTo: descripcionTextField.bottomAnchor, constant: 16),
            categoriaButton.leadingAnchor.constraint(equalTo: codigoTextField.leadingAnchor),
            categoriaButton.trailingAnchor.constraint(equalTo: codigoTextField.trailingAnchor),
            categoriaButton.heightAnchor.constraint(equalToConstant: 50),
            
            marcaButton.topAnchor.constraint(equalTo: categoriaButton.bottomAnchor, constant: 12),
            marcaButton.leadingAnchor.constraint(equalTo: codigoTextField.leadingAnchor),
            marcaButton.trailingAnchor.constraint(equalTo: codigoTextField.trailingAnchor),
            marcaButton.heightAnchor.constraint(equalToConstant: 50),
            
            unidadButton.topAnchor.constraint(equalTo: marcaButton.bottomAnchor, constant: 12),
            unidadButton.leadingAnchor.constraint(equalTo: codigoTextField.leadingAnchor),
            unidadButton.trailingAnchor.constraint(equalTo: codigoTextField.trailingAnchor),
            unidadButton.heightAnchor.constraint(equalToConstant: 50),
            
            estadoLabel.topAnchor.constraint(equalTo: unidadButton.bottomAnchor, constant: 24),
            estadoLabel.leadingAnchor.constraint(equalTo: codigoTextField.leadingAnchor),
            
            estadoSwitch.centerYAnchor.constraint(equalTo: estadoLabel.centerYAnchor),
            estadoSwitch.trailingAnchor.constraint(equalTo: codigoTextField.trailingAnchor),
            
            saveButton.topAnchor.constraint(equalTo: estadoLabel.bottomAnchor, constant: 32),
            saveButton.leadingAnchor.constraint(equalTo: codigoTextField.leadingAnchor),
            saveButton.trailingAnchor.constraint(equalTo: codigoTextField.trailingAnchor),
            saveButton.heightAnchor.constraint(equalToConstant: 54),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
        
        // Tap to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupActions() {
        changePhotoButton.addTarget(self, action: #selector(selectPhotoTapped), for: .touchUpInside)
        imageContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectPhotoTapped)))
        imageContainerView.isUserInteractionEnabled = true
        
        categoriaButton.addTarget(self, action: #selector(selectCategoriaTapped), for: .touchUpInside)
        marcaButton.addTarget(self, action: #selector(selectMarcaTapped), for: .touchUpInside)
        unidadButton.addTarget(self, action: #selector(selectUnidadTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
    }
    
    private func loadPickerData() {
        categorias = viewModel.fetchCategorias()
        marcas = viewModel.fetchMarcas()
        unidades = viewModel.fetchUnidades()
    }
    
    private func configureForEditing() {
        guard let producto = producto else { return }
        
        codigoTextField.text = producto.codigo
        descripcionTextField.text = producto.descripcion
        estadoSwitch.isOn = producto.estado
        
        if let imageData = producto.imagen, let image = UIImage(data: imageData) {
            productoImageView.image = image
            productoImageView.contentMode = .scaleAspectFill
            selectedImage = imageData
        }
        
        if let cat = producto.categoria {
            selectedCategoria = cat
            categoriaButton.setTitle(cat.nombre, for: .normal)
        }
        
        if let mar = producto.marca {
            selectedMarca = mar
            marcaButton.setTitle(mar.nombre, for: .normal)
        }
        
        if let uni = producto.unidad {
            selectedUnidad = uni
            unidadButton.setTitle(uni.displayName, for: .normal)
        }
    }
    
    // MARK: - Actions
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func selectPhotoTapped() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc private func selectCategoriaTapped() {
        showPickerAlert(
            title: "Seleccionar Categoría",
            items: categorias.map { $0.nombre },
            addAction: { [weak self] in
                self?.navigateToModule(CategoriasViewController())
            }
        ) { [weak self] index in
            self?.selectedCategoria = self?.categorias[index]
            self?.categoriaButton.setTitle(self?.categorias[index].nombre, for: .normal)
        }
    }
    
    @objc private func selectMarcaTapped() {
        showPickerAlert(
            title: "Seleccionar Marca",
            items: marcas.map { $0.nombre },
            addAction: { [weak self] in
                self?.navigateToModule(MarcasViewController())
            }
        ) { [weak self] index in
            self?.selectedMarca = self?.marcas[index]
            self?.marcaButton.setTitle(self?.marcas[index].nombre, for: .normal)
        }
    }
    
    @objc private func selectUnidadTapped() {
        showPickerAlert(
            title: "Seleccionar Unidad",
            items: unidades.map { $0.displayName },
            addAction: { [weak self] in
                self?.navigateToModule(UnidadesViewController())
            }
        ) { [weak self] index in
            self?.selectedUnidad = self?.unidades[index]
            self?.unidadButton.setTitle(self?.unidades[index].displayName, for: .normal)
        }
    }
    
    @objc private func saveTapped() {
        let codigo = codigoTextField.text ?? ""
        let descripcion = descripcionTextField.text ?? ""
        
        if let producto = producto {
            viewModel.updateProducto(
                producto,
                codigo: codigo,
                descripcion: descripcion,
                categoria: selectedCategoria,
                marca: selectedMarca,
                unidad: selectedUnidad,
                imagen: selectedImage
            )
            producto.estado = estadoSwitch.isOn
        } else {
            viewModel.addProducto(
                codigo: codigo,
                descripcion: descripcion,
                categoria: selectedCategoria,
                marca: selectedMarca,
                unidad: selectedUnidad,
                imagen: selectedImage
            )
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Helpers
    
    private func showPickerAlert(title: String, items: [String], addAction: @escaping () -> Void, selection: @escaping (Int) -> Void) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        
        for (index, item) in items.enumerated() {
            alert.addAction(UIAlertAction(title: item, style: .default) { _ in
                selection(index)
            })
        }
        
        alert.addAction(UIAlertAction(title: "➕ Gestionar...", style: .default) { _ in
            addAction()
        })
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func navigateToModule(_ viewController: UIViewController) {
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - PHPickerViewControllerDelegate

extension ProductoFormViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let result = results.first else { return }
        
        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            guard let image = object as? UIImage else { return }
            
            DispatchQueue.main.async {
                self?.productoImageView.image = image
                self?.productoImageView.contentMode = .scaleAspectFill
                self?.selectedImage = image.jpegData(compressionQuality: 0.7)
            }
        }
    }
}
